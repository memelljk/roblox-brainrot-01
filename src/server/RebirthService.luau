-- RebirthService: start over richer. A rebirth wipes your cash and your
-- whole brainrot collection, but every rebirth adds a permanent +25%
-- income multiplier. The price grows with each rebirth, so the ladder
-- stays a real decision: cash out your lead, or keep climbing.

local BrainrotData = require(script.Parent.BrainrotData)
local GameState = require(script.Parent.GameState)

local RebirthService = {}

local REBIRTH_BASE_COST = 10000
local REBIRTH_MULTIPLIER_GAIN = 0.25

function RebirthService.rebirthCost(player)
	local record = GameState.getPlayer(player)
	return REBIRTH_BASE_COST * (record.rebirths + 1) * (record.rebirths + 1)
end

function RebirthService.canRebirth(player)
	local record = GameState.getPlayer(player)
	return record.cash >= RebirthService.rebirthCost(player)
end

function RebirthService.rebirth(player)
	local record = GameState.getPlayer(player)
	local cost = RebirthService.rebirthCost(player)
	if record.cash < cost then
		return false, "Rebirth butuh " .. BrainrotData.formatMoney(cost) .. ". Uangmu " .. BrainrotData.formatMoney(record.cash) .. "."
	end
	-- Destroy every owned brainrot model and free its slot.
	local plot = GameState.getPlotOf(player)
	for _, brainrot in ipairs(record.brainrots) do
		if brainrot.model ~= nil then
			brainrot.model:Destroy()
		end
	end
	if plot ~= nil then
		for _, slot in ipairs(plot.slots) do
			slot.brainrotUid = 0
		end
	end
	record.brainrots = {}
	record.cash = 0
	record.rebirths = record.rebirths + 1
	record.incomeMultiplier = 1 + record.rebirths * REBIRTH_MULTIPLIER_GAIN
	return true, "REBIRTH #" .. record.rebirths .. "! Penghasilan permanen +" .. math.floor(REBIRTH_MULTIPLIER_GAIN * 100) .. "% (total x" .. record.incomeMultiplier .. "). Kumpulkan lagi dari nol!"
end

return RebirthService
