-- EventService: the tsunami. Every few minutes a warning sounds, then a
-- giant wave sweeps the island from north to south. Anyone caught outside
-- their own base loses 5% of their cash and is washed back to spawn.
-- Brainrots on plots are safe: the dash home is the whole point.

local GameState = require(script.Parent.GameState)

local EventService = {}

local CALM_SECONDS = 150
local WARNING_SECONDS = 15
local WAVE_SECONDS = 10
local WAVE_PENALTY = 0.05

local notifyAll = nil
local onWaveHit = nil

function EventService.setNotify(fn)
	notifyAll = fn
end

function EventService.setOnWaveHit(fn)
	onWaveHit = fn
end

local function announce(text)
	if notifyAll ~= nil then
		notifyAll(text)
	end
end

function EventService.start()
	task.spawn(function()
		while true do
			GameState.event.phase = "calm"
			GameState.event.secondsLeft = CALM_SECONDS
			for left = CALM_SECONDS, 1, -1 do
				GameState.event.secondsLeft = left
				task.wait(1)
			end
			GameState.event.phase = "warning"
			GameState.event.secondsLeft = WARNING_SECONDS
			announce("TSUNAMI DATANG! Lari pulang ke basemu dalam " .. WARNING_SECONDS .. " detik!")
			for left = WARNING_SECONDS, 1, -1 do
				GameState.event.secondsLeft = left
				task.wait(1)
			end
			EventService.runWave()
			GameState.event.phase = "calm"
			GameState.event.waveActive = false
		end
	end)
end

-- Is this player standing inside their own plot right now?
function EventService.isPlayerHome(player)
	local record = GameState.getPlayer(player)
	if record.plotId == 0 then
		return false
	end
	local character = player.Character
	if character == nil then
		return false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return false
	end
	local plot = GameState.plots[record.plotId]
	local pos = root.Position
	return math.abs(pos.X - plot.centreX) <= 11 and math.abs(pos.Z - plot.centreZ) <= 11
end

function EventService.runWave()
	GameState.event.phase = "wave"
	GameState.event.waveActive = true
	GameState.event.secondsLeft = WAVE_SECONDS
	announce("TSUNAMI! Ombak menyapu pulau!")
	local wave = Instance.new("Part")
	wave.Name = "TsunamiWave"
	wave.Size = Vector3.new(220, 14, 12)
	wave.Color = Color3.fromRGB(40, 120, 255)
	wave.Material = Enum.Material.Neon
	wave.Transparency = 0.35
	wave.Anchored = true
	wave.CanCollide = false
	wave.Position = Vector3.new(0, 7, -100)
	wave.Parent = workspace
	-- Sweep south across the whole island over WAVE_SECONDS.
	local steps = 50
	for step = 1, steps do
		local z = -100 + (step / steps) * 200
		wave.Position = Vector3.new(0, 7, z)
		task.wait(WAVE_SECONDS / steps)
	end
	wave:Destroy()
	-- Anyone still outside their base pays for it.
	local Players = game:GetService("Players")
	for _, player in ipairs(Players:GetPlayers()) do
		if not EventService.isPlayerHome(player) then
			local record = GameState.getPlayer(player)
			local lost = math.floor(record.cash * WAVE_PENALTY)
			record.cash = record.cash - lost
			local character = player.Character
			if character ~= nil then
				local root = character:FindFirstChild("HumanoidRootPart")
				if root ~= nil then
					root.CFrame = CFrame.new(0, 3, 85)
				end
			end
			if onWaveHit ~= nil then
				onWaveHit(player, lost)
			end
		end
	end
	announce("Tsunami lewat! Yang di luar base tadi tersapu ombak.")
end

return EventService
