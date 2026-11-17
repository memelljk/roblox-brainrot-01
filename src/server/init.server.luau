-- init.server: Pinisi Brainrot Bay's server entry point.
-- Wires the services together: plots on join, the conveyor, money ticks,
-- stealing, the tsunami, rebirths and mutations, and the remotes the
-- client talks to. It also pushes a full state snapshot to every client
-- once a second, so the HUD never goes stale.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotData = require(script.Parent.BrainrotData)
local BrainrotFactory = require(script.Parent.BrainrotFactory)
local GameState = require(script.Parent.GameState)
local MoneyService = require(script.Parent.MoneyService)
local BaseService = require(script.Parent.BaseService)
local SpawnerService = require(script.Parent.SpawnerService)
local StealService = require(script.Parent.StealService)
local EventService = require(script.Parent.EventService)
local RebirthService = require(script.Parent.RebirthService)
local MutationService = require(script.Parent.MutationService)

local ClientUpdate = ReplicatedStorage:WaitForChild("ClientUpdate")
local BuyBrainrot = ReplicatedStorage:WaitForChild("BuyBrainrot")
local StealBrainrot = ReplicatedStorage:WaitForChild("StealBrainrot")
local LockBase = ReplicatedStorage:WaitForChild("LockBase")
local RequestRebirth = ReplicatedStorage:WaitForChild("RequestRebirth")
local RequestReroll = ReplicatedStorage:WaitForChild("RequestReroll")
local SellBrainrot = ReplicatedStorage:WaitForChild("SellBrainrot")
local BuyUpgrade = ReplicatedStorage:WaitForChild("BuyUpgrade")

BaseService.setup()
SpawnerService.start()
EventService.start()
MoneyService.start()

-- Send one player a short toast message on their screen.
local function notifyPlayer(player, text)
	ClientUpdate:FireClient(player, { type = "notify", text = text })
end

StealService.setNotify(notifyPlayer)
EventService.setNotify(function(text)
	for _, player in ipairs(Players:GetPlayers()) do
		notifyPlayer(player, text)
	end
end)
EventService.setOnWaveHit(function(player, lost)
	notifyPlayer(player, "Tsunami menyapumu! Kehilangan " .. BrainrotData.formatMoney(lost) .. ". Lain kali lari pulang!")
end)

-- The whole snapshot the client HUD is drawn from.
local function buildSnapshot(player)
	local record = GameState.getPlayer(player)
	local owned = {}
	for _, brainrot in ipairs(record.brainrots) do
		local char = BrainrotData.getById(brainrot.charId)
		table.insert(owned, {
			uid = brainrot.uid,
			name = char.name,
			rarity = char.rarity,
			mutation = brainrot.mutation.name,
			income = brainrot.income,
			slot = brainrot.slot,
		})
	end
	return {
		type = "state",
		cash = math.floor(record.cash),
		income = math.floor(GameState.incomePerSecond(player)),
		rebirths = record.rebirths,
		multiplier = record.incomeMultiplier,
		plotId = record.plotId,
		upgradeLevel = record.upgradeLevel,
		upgradeCost = BaseService.upgradeCost(player),
		rebirthCost = RebirthService.rebirthCost(player),
		lockSecondsLeft = math.max(0, record.lockUntil - os.time()),
		lockCooldownLeft = math.max(0, record.lockCooldownUntil - os.time()),
		owned = owned,
		belt = SpawnerService.beltSnapshot(),
		eventPhase = GameState.event.phase,
		eventSecondsLeft = GameState.event.secondsLeft,
	}
end

local function pushState(player)
	ClientUpdate:FireClient(player, buildSnapshot(player))
end

-- Push fresh state to everyone once a second (money ticks, belt, timers).
task.spawn(function()
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			pushState(player)
		end
	end
end)

-- A player joins: claim a plot, greet them, send the first snapshot.
local function onPlayerAdded(player)
	local plot = BaseService.assignPlot(player)
	if plot == nil then
		notifyPlayer(player, "Pulau penuh! Semua 8 base sudah terisi.")
	else
		notifyPlayer(player, "Selamat datang di Pinisi Brainrot Bay! Basemu: Base " .. plot.id .. ". Beli brainrot di conveyor tengah!")
	end
	pushState(player)
end

-- A player leaves: clear their plot (their brainrot models go with them).
local function onPlayerRemoving(player)
	local record = GameState.players[player.UserId]
	if record ~= nil then
		for _, brainrot in ipairs(record.brainrots) do
			if brainrot.model ~= nil then
				brainrot.model:Destroy()
			end
		end
	end
	BaseService.releasePlot(player)
	GameState.removePlayer(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Buy off the conveyor, then build the brainrot on the buyer's plot.
BuyBrainrot.OnServerInvoke = function(player, beltUid)
	local ok, message, brainrot = MoneyService.buyBrainrot(player, beltUid)
	if not ok then
		return false, message
	end
	local plot = GameState.getPlotOf(player)
	local char = BrainrotData.getById(brainrot.charId)
	local slotPos = plot.slots[brainrot.slot]
	local model = BrainrotFactory.buildBrainrot(char, brainrot.mutation, Vector3.new(slotPos.x, 2.5, slotPos.z), 0)
	model.Name = "OwnedBrainrot_" .. brainrot.uid
	model.Parent = workspace
	brainrot.model = model
	StealService.watchBrainrot(model, brainrot.uid)
	notifyPlayer(player, message)
	pushState(player)
	return true, message
end

-- Steal by clicking a brainrot's body in the world (its ClickDetector).
-- This remote is the same action for touch and gamepad players.
StealBrainrot.OnServerInvoke = function(player, brainrotUid)
	StealService.trySteal(player, brainrotUid)
	return true, "Mencoba mencuri..."
end

LockBase.OnServerEvent:Connect(function(player)
	local ok, message = BaseService.lockBase(player)
	notifyPlayer(player, message)
	pushState(player)
end)

RequestRebirth.OnServerEvent:Connect(function(player)
	local ok, message = RebirthService.rebirth(player)
	notifyPlayer(player, message)
	pushState(player)
end)

RequestReroll.OnServerEvent:Connect(function(player, brainrotUid)
	local ok, message = MutationService.reroll(player, brainrotUid)
	notifyPlayer(player, message)
	pushState(player)
end)

SellBrainrot.OnServerEvent:Connect(function(player, brainrotUid)
	local ok, message = MoneyService.sellBrainrot(player, brainrotUid)
	notifyPlayer(player, message)
	pushState(player)
end)

BuyUpgrade.OnServerEvent:Connect(function(player)
	local ok, message = BaseService.buyUpgrade(player)
	notifyPlayer(player, message)
	pushState(player)
end)

print("Pinisi Brainrot Bay server ready: 8 plots, 12 brainrots, conveyor running.")
