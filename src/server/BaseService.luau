-- BaseService: owns the 8 plots. It hands a free plot to each player who
-- joins, writes the owner's name on the plot's sign board, and runs the
-- base lock: a locked base cannot be stolen from, and shows a glowing wall
-- while the lock lasts. Upgrades raise the whole base's income.

local GameState = require(script.Parent.GameState)
local BrainrotData = require(script.Parent.BrainrotData)

local BaseService = {}

local LOCK_SECONDS = 60
local LOCK_COOLDOWN_SECONDS = 120
local UPGRADE_BASE_COST = 250
local MAX_UPGRADE = 10

function BaseService.setup()
	GameState.definePlots()
end

-- Put the owner's name on the plot sign (a BillboardGui on the board part).
function BaseService.paintSign(plot, player)
	local board = workspace:FindFirstChild("Plot" .. plot.id .. "SignBoard")
	if board == nil then
		return
	end
	local old = board:FindFirstChild("PlotSign")
	if old ~= nil then
		old:Destroy()
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PlotSign"
	billboard.Size = UDim2.new(0, 200, 0, 60)
	billboard.StudsOffset = Vector3.new(0, 0, 0)
	billboard.Parent = board
	local ownerLabel = Instance.new("TextLabel")
	ownerLabel.Size = UDim2.new(1, 0, 0.5, 0)
	ownerLabel.BackgroundTransparency = 1
	ownerLabel.Text = player.DisplayName
	ownerLabel.TextColor3 = Color3.fromRGB(30, 30, 30)
	ownerLabel.TextScaled = true
	ownerLabel.Font = Enum.Font.SourceSansBold
	ownerLabel.Parent = billboard
	local baseLabel = Instance.new("TextLabel")
	baseLabel.Position = UDim2.new(0, 0, 0.5, 0)
	baseLabel.Size = UDim2.new(1, 0, 0.5, 0)
	baseLabel.BackgroundTransparency = 1
	baseLabel.Text = "BASE " .. plot.id
	baseLabel.TextColor3 = Color3.fromRGB(90, 90, 90)
	baseLabel.TextScaled = true
	baseLabel.Font = Enum.Font.SourceSans
	baseLabel.Parent = billboard
end

function BaseService.assignPlot(player)
	local plot = GameState.claimFreePlot(player)
	if plot == nil then
		return nil
	end
	BaseService.paintSign(plot, player)
	return plot
end

function BaseService.releasePlot(player)
	GameState.freePlot(player)
end

-- Is this plot's lock up right now?
function BaseService.isLocked(plot)
	local owner = nil
	local Players = game:GetService("Players")
	for _, player in ipairs(Players:GetPlayers()) do
		if player.UserId == plot.ownerUserId then
			owner = player
			break
		end
	end
	if owner == nil then
		return false
	end
	local record = GameState.getPlayer(owner)
	return os.time() < record.lockUntil
end

-- Lock your own base for 60 seconds. Cooldown 120 seconds after it ends.
function BaseService.lockBase(player)
	local record = GameState.getPlayer(player)
	local now = os.time()
	if now < record.lockCooldownUntil then
		local left = record.lockCooldownUntil - now
		return false, "Kunci masih cooldown, tunggu " .. left .. " detik lagi."
	end
	if now < record.lockUntil then
		return false, "Basemu sudah terkunci."
	end
	record.lockUntil = now + LOCK_SECONDS
	record.lockCooldownUntil = now + LOCK_SECONDS + LOCK_COOLDOWN_SECONDS
	BaseService.showLockWall(player, true)
	task.delay(LOCK_SECONDS, function()
		BaseService.showLockWall(player, false)
	end)
	return true, "Base terkunci " .. LOCK_SECONDS .. " detik! Tidak ada yang bisa mencuri."
end

-- A glowing neon wall across the plot's open side while it is locked.
function BaseService.showLockWall(player, show)
	local record = GameState.getPlayer(player)
	if record.plotId == 0 then
		return
	end
	local plot = GameState.plots[record.plotId]
	local wallName = "Plot" .. plot.id .. "LockWall"
	local old = workspace:FindFirstChild(wallName)
	if old ~= nil then
		old:Destroy()
	end
	if not show then
		return
	end
	local side = 1
	if plot.centreX < 0 then
		side = -1
	end
	local wall = Instance.new("Part")
	wall.Name = wallName
	wall.Size = Vector3.new(1, 6, 20)
	wall.Position = Vector3.new(plot.centreX - side * 10, 4, plot.centreZ)
	wall.Color = Color3.fromRGB(80, 160, 255)
	wall.Material = Enum.Material.Neon
	wall.Transparency = 0.4
	wall.Anchored = true
	wall.CanCollide = true
	wall.Parent = workspace
end

-- Upgrade the base: +10% income per level, cost grows with the level.
function BaseService.upgradeCost(player)
	local record = GameState.getPlayer(player)
	return UPGRADE_BASE_COST * (record.upgradeLevel + 1) * (record.upgradeLevel + 1)
end

function BaseService.buyUpgrade(player)
	local record = GameState.getPlayer(player)
	if record.upgradeLevel >= MAX_UPGRADE then
		return false, "Basemu sudah level maksimal!"
	end
	local cost = BaseService.upgradeCost(player)
	if record.cash < cost then
		return false, "Uangmu kurang! Upgrade butuh " .. BrainrotData.formatMoney(cost) .. "."
	end
	record.cash = record.cash - cost
	record.upgradeLevel = record.upgradeLevel + 1
	return true, "Base naik ke level " .. record.upgradeLevel .. "! Semua brainrot +10% penghasilan."
end

return BaseService
