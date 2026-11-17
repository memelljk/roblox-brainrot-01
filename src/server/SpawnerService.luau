-- SpawnerService: the conveyor. New brainrots roll in at the north end,
-- walk south down the belt, and fall off the end if nobody buys them.
-- Each belt brainrot carries its uid, character, mutation and price, so
-- the client can show it in the shop list and MoneyService can sell it.

local BrainrotData = require(script.Parent.BrainrotData)
local BrainrotFactory = require(script.Parent.BrainrotFactory)
local GameState = require(script.Parent.GameState)

local SpawnerService = {}

local BELT_START_Z = -55
local BELT_END_Z = 58
local BELT_SPEED = 3
local SPAWN_EVERY_SECONDS = 8

function SpawnerService.start()
	task.spawn(function()
		while true do
			task.wait(SPAWN_EVERY_SECONDS)
			SpawnerService.spawnOne()
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.2)
			SpawnerService.stepBelt(0.2)
		end
	end)
end

function SpawnerService.spawnOne()
	if not GameState.beltHasRoom() then
		return
	end
	local char = BrainrotData.rollCharacter()
	local mutation = BrainrotData.rollMutation()
	local uid = GameState.newBrainrotUid()
	local model = BrainrotFactory.buildBrainrot(char, mutation, Vector3.new(0, 2.5, BELT_START_Z), 180)
	model.Name = "BeltBrainrot_" .. uid
	model.Parent = workspace
	local entry = {
		uid = uid,
		charId = char.id,
		mutation = mutation,
		model = model,
		z = BELT_START_Z,
	}
	table.insert(GameState.belt, entry)
end

-- Walk every belt brainrot a step south; despawn the ones past the end.
function SpawnerService.stepBelt(dt)
	for i = #GameState.belt, 1, -1 do
		local entry = GameState.belt[i]
		entry.z = entry.z + BELT_SPEED * dt
		if entry.z >= BELT_END_Z then
			if entry.model ~= nil then
				entry.model:Destroy()
			end
			table.remove(GameState.belt, i)
		elseif entry.model ~= nil then
			local bob = math.sin(entry.z * 0.5) * 0.2
			BrainrotFactory.moveModel(entry.model, Vector3.new(0, 2.5 + bob, entry.z), 180)
		end
	end
end

-- The shop list the client shows: one row per brainrot on the belt.
function SpawnerService.beltSnapshot()
	local rows = {}
	for _, entry in ipairs(GameState.belt) do
		local char = BrainrotData.getById(entry.charId)
		table.insert(rows, {
			uid = entry.uid,
			name = char.name,
			rarity = char.rarity,
			price = char.price,
			income = char.income * entry.mutation.multiplier,
			mutation = entry.mutation.name,
			z = math.floor(entry.z),
		})
	end
	return rows
end

return SpawnerService
