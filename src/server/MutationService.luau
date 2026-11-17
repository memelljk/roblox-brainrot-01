-- MutationService: re-roll a brainrot's mutation. Pay a fee and the
-- mutation is rolled again: Normal, Golden (x2), Diamond (x4) or Rainbow
-- (x8). The new income applies at once, and the 3D body is rebuilt so the
-- glow matches the new mutation.

local BrainrotData = require(script.Parent.BrainrotData)
local BrainrotFactory = require(script.Parent.BrainrotFactory)
local GameState = require(script.Parent.GameState)
local StealService = require(script.Parent.StealService)

local MutationService = {}

local REROLL_BASE_COST = 250

function MutationService.rerollCost(brainrot)
	local char = BrainrotData.getById(brainrot.charId)
	return REROLL_BASE_COST + math.floor(char.price / 4)
end

function MutationService.reroll(player, brainrotUid)
	local record = GameState.getPlayer(player)
	local found = nil
	for _, brainrot in ipairs(record.brainrots) do
		if brainrot.uid == brainrotUid then
			found = brainrot
			break
		end
	end
	if found == nil then
		return false, "Brainrot tidak ditemukan."
	end
	local cost = MutationService.rerollCost(found)
	if record.cash < cost then
		return false, "Re-roll mutasi butuh " .. BrainrotData.formatMoney(cost) .. "."
	end
	record.cash = record.cash - cost
	local oldName = found.mutation.name
	local mutation = BrainrotData.rollMutation()
	found.mutation = mutation
	local char = BrainrotData.getById(found.charId)
	found.income = char.income * mutation.multiplier
	-- Rebuild the 3D body so its glow matches the new mutation.
	local plot = GameState.getPlotOf(player)
	if plot ~= nil and found.model ~= nil then
		local slotPos = plot.slots[found.slot]
		local facing = 0
		found.model:Destroy()
		local model = BrainrotFactory.buildBrainrot(char, mutation, Vector3.new(slotPos.x, 2.5, slotPos.z), facing)
		model.Name = "OwnedBrainrot_" .. found.uid
		model.Parent = workspace
		found.model = model
		-- The rebuilt body has a fresh ClickDetector: wire it to stealing again.
		StealService.watchBrainrot(model, found.uid)
	end
	if mutation.name == oldName then
		return true, "Mutasi tetap " .. mutation.name .. ". Coba lagi!"
	end
	return true, "Mutasi " .. char.name .. ": " .. oldName .. " -> " .. mutation.name .. " (x" .. mutation.multiplier .. " penghasilan)!"
end

return MutationService
