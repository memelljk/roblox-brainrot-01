-- GameState: the single place all player state lives.
-- Every service reads and writes through this module, so no service keeps
-- its own copy of a player's money, plot, brainrots or rebirths.
-- A player record: cash, rebirths, incomeMultiplier, plotId, lockUntil,
-- lockCooldownUntil, stealCooldownUntil, brainrots (list of owned brainrot
-- records), upgrades (base level). A brainrot record: uid, charId, mutation,
-- income, slot, model (the 3D Model in the world, or nil while on the belt).

local GameState = {}

GameState.players = {}
GameState.plots = {}
GameState.belt = {}
GameState.event = { phase = "calm", secondsLeft = 150, waveActive = false }
GameState.nextBrainrotUid = 1

local START_CASH = 100
local MAX_BELT = 6

function GameState.newPlayerRecord()
	return {
		cash = START_CASH,
		rebirths = 0,
		incomeMultiplier = 1,
		plotId = 0,
		lockUntil = 0,
		lockCooldownUntil = 0,
		stealCooldownUntil = 0,
		upgradeLevel = 0,
		brainrots = {},
	}
end

function GameState.getPlayer(player)
	local record = GameState.players[player.UserId]
	if record == nil then
		record = GameState.newPlayerRecord()
		GameState.players[player.UserId] = record
	end
	return record
end

function GameState.removePlayer(player)
	GameState.players[player.UserId] = nil
end

-- The 8 plots from default.project.json: centre, floor colour, sign board.
function GameState.definePlots()
	local centres = {
		{ x = -26, z = -54 },
		{ x = -26, z = -18 },
		{ x = -26, z = 18 },
		{ x = -26, z = 54 },
		{ x = 26, z = -54 },
		{ x = 26, z = -18 },
		{ x = 26, z = 18 },
		{ x = 26, z = 54 },
	}
	for i, centre in ipairs(centres) do
		GameState.plots[i] = {
			id = i,
			centreX = centre.x,
			centreZ = centre.z,
			ownerUserId = 0,
			slots = {},
		}
		-- 8 slots per plot, two rows of four, matching the Pad parts.
		for slot = 1, 8 do
			local col = (slot - 1) % 4
			local row = math.floor((slot - 1) / 4)
			local slotX = centre.x - 6 + col * 4
			local slotZ = centre.z - 4 + row * 8
			GameState.plots[i].slots[slot] = { x = slotX, z = slotZ, brainrotUid = 0 }
		end
	end
end

-- First free plot, or 0 when the island is full.
function GameState.claimFreePlot(player)
	for _, plot in ipairs(GameState.plots) do
		if plot.ownerUserId == 0 then
			plot.ownerUserId = player.UserId
			GameState.getPlayer(player).plotId = plot.id
			return plot
		end
	end
	return nil
end

function GameState.freePlot(player)
	local record = GameState.players[player.UserId]
	if record ~= nil and record.plotId > 0 then
		local plot = GameState.plots[record.plotId]
		if plot ~= nil then
			plot.ownerUserId = 0
			for _, slot in ipairs(plot.slots) do
				slot.brainrotUid = 0
			end
		end
		record.plotId = 0
	end
end

function GameState.getPlot(plotId)
	return GameState.plots[plotId]
end

function GameState.getPlotOf(player)
	local record = GameState.getPlayer(player)
	if record.plotId == 0 then
		return nil
	end
	return GameState.plots[record.plotId]
end

-- Next free slot number on a plot, or 0 when the plot is full.
function GameState.nextFreeSlot(plot)
	for i, slot in ipairs(plot.slots) do
		if slot.brainrotUid == 0 then
			return i
		end
	end
	return 0
end

function GameState.newBrainrotUid()
	local uid = GameState.nextBrainrotUid
	GameState.nextBrainrotUid = GameState.nextBrainrotUid + 1
	return uid
end

-- Total money per second of one player's whole collection, after multipliers.
function GameState.incomePerSecond(player)
	local record = GameState.getPlayer(player)
	local total = 0
	for _, brainrot in ipairs(record.brainrots) do
		total = total + brainrot.income
	end
	total = total * record.incomeMultiplier
	total = total * (1 + record.upgradeLevel * 0.1)
	return total
end

-- Belt capacity: how many brainrots may walk the conveyor at once.
function GameState.beltHasRoom()
	return #GameState.belt < MAX_BELT
end

return GameState
