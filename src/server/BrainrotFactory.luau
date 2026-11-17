-- BrainrotFactory: builds one brainrot as a real 3D Model from parts.
-- Body, head, eyes and one signature accessory per character, plus a
-- floating BillboardGui with the name, rarity and money per second, and a
-- ClickDetector so other players can try to steal it. Models are anchored
-- and walk by CFrame, so they never fall through the world.

local BrainrotData = require(script.Parent.BrainrotData)

local BrainrotFactory = {}

local function makePart(name, size, color, material, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = Color3.fromRGB(color[1], color[2], color[3])
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = Enum.SurfaceType.Smooth
	if shape ~= nil then
		part.Shape = shape
	end
	return part
end

-- One signature prop per character, built from two or three parts.
local function addAccessory(model, accessory, size, bodyColor)
	local s = size
	if accessory == "fin" then
		local fin = makePart("Fin", Vector3.new(0.3, 1.4 * s, 1.8 * s), { 255, 180, 60 }, Enum.Material.Neon)
		fin.CFrame = model:GetPivot() * CFrame.new(0, 1.2 * s, 0)
		fin.Parent = model
	elseif accessory == "skates" then
		for _, side in ipairs({ -0.8, 0.8 }) do
			local skate = makePart("Skate", Vector3.new(0.7 * s, 0.4 * s, 1.6 * s), { 200, 60, 60 }, Enum.Material.Metal)
			skate.CFrame = model:GetPivot() * CFrame.new(side * s, -1.2 * s, 0.3 * s)
			skate.Parent = model
		end
	elseif accessory == "paper" then
		local fold = makePart("PaperFold", Vector3.new(2.6 * s, 0.3 * s, 2.6 * s), { 255, 220, 120 }, Enum.Material.SmoothPlastic)
		fold.CFrame = model:GetPivot() * CFrame.new(0, 1.6 * s, 0)
		fold.Parent = model
	elseif accessory == "ice" then
		local cup = makePart("CoconutCup", Vector3.new(1.2 * s, 1.2 * s, 1.2 * s), { 120, 80, 40 }, Enum.Material.Wood, Enum.PartType.Ball)
		cup.CFrame = model:GetPivot() * CFrame.new(1.4 * s, 0.4 * s, 0)
		cup.Parent = model
		local straw = makePart("Straw", Vector3.new(0.25 * s, 1.6 * s, 0.25 * s), { 255, 80, 120 }, Enum.Material.Neon)
		straw.CFrame = model:GetPivot() * CFrame.new(1.4 * s, 1.4 * s, 0)
		straw.Parent = model
	elseif accessory == "headphones" then
		for _, side in ipairs({ -1.1, 1.1 }) do
			local cup = makePart("Headphone", Vector3.new(0.5 * s, 1.1 * s, 1.1 * s), { 40, 40, 40 }, Enum.Material.Metal)
			cup.CFrame = model:GetPivot() * CFrame.new(side * s, 1.1 * s, 0)
			cup.Parent = model
		end
		local band = makePart("Headband", Vector3.new(2.6 * s, 0.4 * s, 0.4 * s), { 40, 40, 40 }, Enum.Material.Metal)
		band.CFrame = model:GetPivot() * CFrame.new(0, 1.9 * s, 0)
		band.Parent = model
	elseif accessory == "wok" then
		local wok = makePart("Wok", Vector3.new(2.4 * s, 0.5 * s, 2.4 * s), { 60, 60, 60 }, Enum.Material.Metal, Enum.PartType.Ball)
		wok.CFrame = model:GetPivot() * CFrame.new(0, 1.7 * s, 0)
		wok.Parent = model
	elseif accessory == "sail" then
		local mast = makePart("Mast", Vector3.new(0.3 * s, 3.2 * s, 0.3 * s), { 120, 80, 40 }, Enum.Material.Wood)
		mast.CFrame = model:GetPivot() * CFrame.new(0, 2.4 * s, 0)
		mast.Parent = model
		local sail = makePart("Sail", Vector3.new(2.6 * s, 2.4 * s, 0.2 * s), { 255, 245, 220 }, Enum.Material.Fabric)
		sail.CFrame = model:GetPivot() * CFrame.new(0, 2.6 * s, 0)
		sail.Parent = model
	elseif accessory == "mic" then
		local stick = makePart("MicStick", Vector3.new(0.4 * s, 1.6 * s, 0.4 * s), { 80, 80, 80 }, Enum.Material.Metal)
		stick.CFrame = model:GetPivot() * CFrame.new(1.5 * s, 0.6 * s, 0)
		stick.Parent = model
		local ball = makePart("MicBall", Vector3.new(0.9 * s, 0.9 * s, 0.9 * s), { 220, 220, 230 }, Enum.Material.Metal, Enum.PartType.Ball)
		ball.CFrame = model:GetPivot() * CFrame.new(1.5 * s, 1.7 * s, 0)
		ball.Parent = model
	elseif accessory == "crown" then
		local crown = makePart("Crown", Vector3.new(2.2 * s, 0.8 * s, 2.2 * s), { 255, 215, 0 }, Enum.Material.Neon)
		crown.CFrame = model:GetPivot() * CFrame.new(0, 2.1 * s, 0)
		crown.Parent = model
	elseif accessory == "flute" then
		local flute = makePart("Flute", Vector3.new(2.6 * s, 0.4 * s, 0.4 * s), { 90, 200, 110 }, Enum.Material.Wood)
		flute.CFrame = model:GetPivot() * CFrame.new(0.4 * s, 0.4 * s, 1.4 * s)
		flute.Parent = model
	elseif accessory == "turban" then
		local turban = makePart("Turban", Vector3.new(2.6 * s, 1.0 * s, 2.6 * s), { 255, 215, 0 }, Enum.Material.Fabric, Enum.PartType.Ball)
		turban.CFrame = model:GetPivot() * CFrame.new(0, 1.9 * s, 0)
		turban.Parent = model
		local gem = makePart("Gem", Vector3.new(0.7 * s, 0.7 * s, 0.7 * s), { 255, 60, 120 }, Enum.Material.Neon, Enum.PartType.Ball)
		gem.CFrame = model:GetPivot() * CFrame.new(0, 2.0 * s, 1.3 * s)
		gem.Parent = model
	elseif accessory == "wave" then
		local wave = makePart("Wave", Vector3.new(3.4 * s, 0.6 * s, 1.2 * s), { 60, 140, 255 }, Enum.Material.Neon)
		wave.CFrame = model:GetPivot() * CFrame.new(0, -1.1 * s, 0)
		wave.Parent = model
	end
end

-- Build the model at `position`, facing `facing` degrees. Returns the Model.
-- `label` is what the BillboardGui shows: name, rarity and $/s.
function BrainrotFactory.buildBrainrot(char, mutation, position, facing)
	local s = char.size
	local model = Instance.new("Model")
	model.Name = char.name

	local body = makePart("Body", Vector3.new(2.4 * s, 2.2 * s, 2.0 * s), char.body)
	body.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(facing), 0)
	body.Parent = model
	local head = makePart("Head", Vector3.new(1.8 * s, 1.6 * s, 1.8 * s), char.head, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	head.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(facing), 0) * CFrame.new(0, 1.8 * s, 0)
	head.Parent = model
	for _, side in ipairs({ -0.45, 0.45 }) do
		local eye = makePart("Eye", Vector3.new(0.35 * s, 0.5 * s, 0.2 * s), { 20, 20, 20 }, Enum.Material.Neon)
		eye.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(facing), 0) * CFrame.new(side * s, 1.9 * s, 0.95 * s)
		eye.Parent = model
	end
	-- Golden and better mutations tint the whole body with their glow colour.
	if mutation ~= nil and mutation.name ~= "Normal" then
		body.Color = Color3.fromRGB(mutation.color[1], mutation.color[2], mutation.color[3])
		body.Material = Enum.Material.Neon
	end
	model.PrimaryPart = body
	addAccessory(model, char.accessory, s, char.body)

	-- Floating label: name, rarity, mutation and income, readable from afar.
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BrainrotLabel"
	billboard.Size = UDim2.new(0, 220, 0, 70)
	billboard.StudsOffset = Vector3.new(0, 3.6 * s, 0)
	billboard.AlwaysOnTop = false
	billboard.Parent = body
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0.45, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = char.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.2
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.Parent = billboard
	local rarity = BrainrotData.getRarity(char.rarity)
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "RarityLabel"
	rarityLabel.Position = UDim2.new(0, 0, 0.45, 0)
	rarityLabel.Size = UDim2.new(1, 0, 0.3, 0)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = char.rarity .. (mutation ~= nil and mutation.name ~= "Normal" and (" " .. mutation.name) or "")
	rarityLabel.TextColor3 = Color3.fromRGB(rarity.color[1], rarity.color[2], rarity.color[3])
	rarityLabel.TextStrokeTransparency = 0.2
	rarityLabel.TextScaled = true
	rarityLabel.Font = Enum.Font.SourceSansBold
	rarityLabel.Parent = billboard
	local incomeLabel = Instance.new("TextLabel")
	incomeLabel.Name = "IncomeLabel"
	incomeLabel.Position = UDim2.new(0, 0, 0.75, 0)
	incomeLabel.Size = UDim2.new(1, 0, 0.25, 0)
	incomeLabel.BackgroundTransparency = 1
	incomeLabel.Text = BrainrotData.formatMoney(char.income * (mutation ~= nil and mutation.multiplier or 1)) .. "/s"
	incomeLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
	incomeLabel.TextStrokeTransparency = 0.2
	incomeLabel.TextScaled = true
	incomeLabel.Font = Enum.Font.SourceSansBold
	incomeLabel.Parent = billboard

	-- Clicking a brainrot on someone else's plot tries to steal it.
	local click = Instance.new("ClickDetector")
	click.Name = "StealClick"
	click.MaxActivationDistance = 14
	click.Parent = body

	return model
end

-- Move a whole model to a new spot, keeping its facing.
function BrainrotFactory.moveModel(model, position, facing)
	local pivot = CFrame.new(position) * CFrame.Angles(0, math.rad(facing), 0)
	model:PivotTo(pivot)
end

return BrainrotFactory
