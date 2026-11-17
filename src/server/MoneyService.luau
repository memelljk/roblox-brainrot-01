-- MoneyService: pays every player's brainrots once a second and sells
-- brainrots off the conveyor. Cash only ever changes here (and in
-- RebirthService, which resets it), so the economy has one writer.

local BrainrotData = require(script.Parent.BrainrotData)
local GameState = require(script.Parent.GameState)

local MoneyService = {}

local TICK_SECONDS = 1

function MoneyService.start(onPaid)
	task.spawn(function()
		while true do
			task.wait(TICK_SECONDS)
			for userId, record in pairs(GameState.players) do
				local player = MoneyService.findPlayerByUserId(userId)
				if player ~= nil then
					local income = GameState.incomePerSecond(player)
					if income > 0 then
						record.cash = record.cash + income
						if onPaid ~= nil then
							onPaid(player, income)
						end
					end
				end
			end
		end
	end)
end

function MoneyService.findPlayerByUserId(userId)
	local Players = game:GetService("Players")
	for _, player in ipairs(Players:GetPlayers()) do
		if player.UserId == userId then
			return player
		end
	end
	return nil
end

-- Buy a brainrot off the conveyor: checks cash, plot room and the belt id.
-- Returns true plus a message, or false plus the reason it failed.
function MoneyService.buyBrainrot(player, beltUid)
	local record = GameState.getPlayer(player)
	local beltIndex = 0
	local beltEntry = nil
	for i, entry in ipairs(GameState.belt) do
		if entry.uid == beltUid then
			beltIndex = i
			beltEntry = entry
			break
		end
	end
	if beltEntry == nil then
		return false, "Brainrot itu sudah tidak ada di conveyor."
	end
	local char = BrainrotData.getById(beltEntry.charId)
	if char == nil then
		return false, "Brainrot tidak dikenal."
	end
	if record.cash < char.price then
		return false, "Uangmu kurang! Butuh " .. BrainrotData.formatMoney(char.price) .. "."
	end
	local plot = GameState.getPlotOf(player)
	if plot == nil then
		return false, "Kamu belum punya base. Tunggu sebentar."
	end
	local slot = GameState.nextFreeSlot(plot)
	if slot == 0 then
		return false, "Basemu penuh! Rebirth atau upgrade dulu."
	end
	record.cash = record.cash - char.price
	table.remove(GameState.belt, beltIndex)
	-- The belt model leaves the conveyor: it is rebuilt on the buyer's plot.
	if beltEntry.model ~= nil then
		beltEntry.model:Destroy()
	end
	local brainrot = {
		uid = GameState.newBrainrotUid(),
		charId = char.id,
		mutation = beltEntry.mutation,
		income = char.income * beltEntry.mutation.multiplier,
		slot = slot,
		model = nil,
	}
	table.insert(record.brainrots, brainrot)
	plot.slots[slot].brainrotUid = brainrot.uid
	return true, "Kamu membeli " .. char.name .. " (" .. beltEntry.mutation.name .. ") seharga " .. BrainrotData.formatMoney(char.price) .. "!", brainrot
end

-- Sell one owned brainrot back for half its price, freeing its slot.
function MoneyService.sellBrainrot(player, brainrotUid)
	local record = GameState.getPlayer(player)
	for i, brainrot in ipairs(record.brainrots) do
		if brainrot.uid == brainrotUid then
			local char = BrainrotData.getById(brainrot.charId)
			local refund = math.floor(char.price / 2)
			record.cash = record.cash + refund
			table.remove(record.brainrots, i)
			local plot = GameState.getPlotOf(player)
			if plot ~= nil then
				plot.slots[brainrot.slot].brainrotUid = 0
			end
			if brainrot.model ~= nil then
				brainrot.model:Destroy()
			end
			return true, "Dijual " .. char.name .. " seharga " .. BrainrotData.formatMoney(refund) .. "."
		end
	end
	return false, "Brainrot tidak ditemukan."
end

return MoneyService
