-- StealService: stealing. Click a brainrot on someone else's plot and, if
-- their base is unlocked and you have a free slot, you carry it home after
-- a 3 second channel. A lock, a full base or a cooldown stops the steal.
-- The victim is told who took what, so the revenge loop stays alive.

local BrainrotData = require(script.Parent.BrainrotData)
local BrainrotFactory = require(script.Parent.BrainrotFactory)
local GameState = require(script.Parent.GameState)
local BaseService = require(script.Parent.BaseService)

local StealService = {}

local STEAL_CHANNEL_SECONDS = 3
local STEAL_COOLDOWN_SECONDS = 15

local notifyPlayer = nil
local activeSteals = {}

function StealService.setNotify(fn)
	notifyPlayer = fn
end

local function tell(player, text)
	if notifyPlayer ~= nil and player ~= nil then
		notifyPlayer(player, text)
	end
end

-- Wire a placed brainrot's ClickDetector to the steal attempt.
function StealService.watchBrainrot(model, brainrotUid)
	local body = model.PrimaryPart
	if body == nil then
		return
	end
	local click = body:FindFirstChild("StealClick")
	if click == nil then
		return
	end
	click.MouseClick:Connect(function(thief)
		StealService.trySteal(thief, brainrotUid)
	end)
end

function StealService.trySteal(thief, brainrotUid)
	if activeSteals[brainrotUid] then
		tell(thief, "Brainrot itu sedang dicuri orang lain!")
		return
	end
	-- Find the owner and the brainrot record.
	local owner = nil
	local ownerRecord = nil
	local stolen = nil
	for userId, record in pairs(GameState.players) do
		for _, brainrot in ipairs(record.brainrots) do
			if brainrot.uid == brainrotUid then
				stolen = brainrot
				ownerRecord = record
				local Players = game:GetService("Players")
				for _, player in ipairs(Players:GetPlayers()) do
					if player.UserId == userId then
						owner = player
					end
				end
				break
			end
		end
		if stolen ~= nil then
			break
		end
	end
	if stolen == nil or owner == nil then
		tell(thief, "Brainrot itu sudah tidak ada.")
		return
	end
	if owner == thief then
		tell(thief, "Itu brainrotmu sendiri!")
		return
	end
	local ownerPlot = GameState.getPlotOf(owner)
	if ownerPlot == nil then
		return
	end
	if BaseService.isLocked(ownerPlot) then
		tell(thief, "Base " .. owner.DisplayName .. " terkunci! Tidak bisa mencuri.")
		return
	end
	local thiefRecord = GameState.getPlayer(thief)
	local now = os.time()
	if now < thiefRecord.stealCooldownUntil then
		tell(thief, "Tunggu " .. (thiefRecord.stealCooldownUntil - now) .. " detik sebelum mencuri lagi.")
		return
	end
	local thiefPlot = GameState.getPlotOf(thief)
	if thiefPlot == nil then
		tell(thief, "Kamu belum punya base.")
		return
	end
	local slot = GameState.nextFreeSlot(thiefPlot)
	if slot == 0 then
		tell(thief, "Basemu penuh! Tidak ada tempat untuk hasil curian.")
		return
	end
	thiefRecord.stealCooldownUntil = now + STEAL_COOLDOWN_SECONDS
	activeSteals[brainrotUid] = true
	local char = BrainrotData.getById(stolen.charId)
	tell(thief, "Mencuri " .. char.name .. "... jangan sampai ketahuan! (" .. STEAL_CHANNEL_SECONDS .. " detik)")
	tell(owner, thief.DisplayName .. " sedang mencuri " .. char.name .. " dari basemu! Kunci basemu!")
	task.delay(STEAL_CHANNEL_SECONDS, function()
		activeSteals[brainrotUid] = nil
		-- The victim may have left mid-channel: then there is nothing to steal.
		if GameState.players[owner.UserId] ~= ownerRecord then
			tell(thief, "Gagal! Pemiliknya sudah keluar dari game.")
			return
		end
		-- The lock may have gone up mid-channel: the steal fails then.
		if BaseService.isLocked(ownerPlot) then
			tell(thief, "Gagal! " .. owner.DisplayName .. " mengunci basenya tepat waktu.")
			return
		end
		-- Move the brainrot record from the victim to the thief. If the
		-- victim rebirthed mid-channel the record is already gone: cancel.
		local wasOwned = false
		for i, brainrot in ipairs(ownerRecord.brainrots) do
			if brainrot.uid == brainrotUid then
				table.remove(ownerRecord.brainrots, i)
				wasOwned = true
				break
			end
		end
		if not wasOwned then
			tell(thief, "Gagal! Brainrot itu sudah tidak ada di base " .. owner.DisplayName .. ".")
			return
		end
		ownerPlot.slots[stolen.slot].brainrotUid = 0
		stolen.slot = slot
		table.insert(thiefRecord.brainrots, stolen)
		thiefPlot.slots[slot].brainrotUid = brainrotUid
		if stolen.model ~= nil and stolen.model.Parent ~= nil then
			local slotPos = thiefPlot.slots[slot]
			BrainrotFactory.moveModel(stolen.model, Vector3.new(slotPos.x, 2.5, slotPos.z), 0)
		end
		tell(thief, "Berhasil! Kamu mencuri " .. char.name .. " dari " .. owner.DisplayName .. "!")
		tell(owner, thief.DisplayName .. " mencuri " .. char.name .. " dari basemu! Balas dendam!")
	end)
end

return StealService
