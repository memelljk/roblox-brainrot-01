-- ClientUI: the whole HUD of Pinisi Brainrot Bay, built in code.
-- Top right: money and income. Top centre: the tsunami timer. Left side:
-- the conveyor shop (what is walking the belt, with Buy buttons). Right
-- side: your base and its brainrots, each with a mutation re-roll button.
-- Bottom right: Lock, Upgrade and Rebirth. Bottom centre: toasts.
-- Nothing sits in the top-left corner: Roblox's own menu buttons live there.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientUI = {}

local player = Players.LocalPlayer
local refs = {}

-- Keys of the last shop and base lists drawn: the lists are rebuilt only
-- when their contents change, so a 1-second state push never eats a click.
local lastShopKey = ""
local lastBaseKey = ""

local function listKey(rows, fields)
	local parts = {}
	for _, row in ipairs(rows) do
		local bits = {}
		for _, field in ipairs(fields) do
			table.insert(bits, tostring(row[field]))
		end
		table.insert(parts, table.concat(bits, "|"))
	end
	return table.concat(parts, ";")
end

local function makeLabel(parent, name, text, size, position, textSize, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = text
	label.Size = size
	label.Position = position
	label.TextSize = textSize
	label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 1
	label.TextStrokeTransparency = 0.3
	label.Font = Enum.Font.SourceSansBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function makeButton(parent, name, text, size, position, color)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Size = size
	button.Position = position
	button.TextSize = 16
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.BackgroundColor3 = color
	button.Font = Enum.Font.SourceSansBold
	button.BorderSizePixel = 0
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	return button
end

function ClientUI.build()
	local gui = Instance.new("ScreenGui")
	gui.Name = "PinisiGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.Parent = player:WaitForChild("PlayerGui")

	-- Money panel, top right.
	local moneyPanel = Instance.new("Frame")
	moneyPanel.Name = "MoneyPanel"
	moneyPanel.AnchorPoint = Vector2.new(1, 0)
	moneyPanel.Position = UDim2.new(1, -12, 0, 12)
	moneyPanel.Size = UDim2.new(0, 240, 0, 76)
	moneyPanel.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
	moneyPanel.BackgroundTransparency = 0.25
	moneyPanel.BorderSizePixel = 0
	moneyPanel.Parent = gui
	local moneyCorner = Instance.new("UICorner")
	moneyCorner.CornerRadius = UDim.new(0, 10)
	moneyCorner.Parent = moneyPanel
	refs.cashLabel = makeLabel(moneyPanel, "CashLabel", "$100", UDim2.new(1, -16, 0, 36), UDim2.new(0, 8, 0, 4), 26, Color3.fromRGB(120, 255, 120))
	refs.incomeLabel = makeLabel(moneyPanel, "IncomeLabel", "+$0/s", UDim2.new(1, -16, 0, 24), UDim2.new(0, 8, 0, 40), 16, Color3.fromRGB(255, 220, 100))
	refs.rebirthLabel = makeLabel(moneyPanel, "RebirthLabel", "Rebirth 0 (x1)", UDim2.new(1, -16, 0, 18), UDim2.new(0, 8, 0, 58), 13, Color3.fromRGB(200, 200, 255))

	-- Tsunami timer, top centre.
	refs.eventLabel = makeLabel(gui, "EventLabel", "Ombak tenang", UDim2.new(0, 420, 0, 30), UDim2.new(0.5, -210, 0, 12), 20, Color3.fromRGB(140, 210, 255))
	refs.eventLabel.TextXAlignment = Enum.TextXAlignment.Center

	-- Conveyor shop, left side, clear of the Roblox menu corner.
	local shopFrame = Instance.new("Frame")
	shopFrame.Name = "ShopFrame"
	shopFrame.Position = UDim2.new(0, 12, 0, 110)
	shopFrame.Size = UDim2.new(0, 300, 0, 380)
	shopFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
	shopFrame.BackgroundTransparency = 0.25
	shopFrame.BorderSizePixel = 0
	shopFrame.Parent = gui
	local shopCorner = Instance.new("UICorner")
	shopCorner.CornerRadius = UDim.new(0, 10)
	shopCorner.Parent = shopFrame
	makeLabel(shopFrame, "ShopTitle", "CONVEYOR - BELI BRAINROT", UDim2.new(1, -16, 0, 28), UDim2.new(0, 8, 0, 6), 17, Color3.fromRGB(255, 220, 100))
	local shopList = Instance.new("ScrollingFrame")
	shopList.Name = "ShopList"
	shopList.Position = UDim2.new(0, 8, 0, 40)
	shopList.Size = UDim2.new(1, -16, 1, -48)
	shopList.BackgroundTransparency = 1
	shopList.ScrollBarThickness = 4
	shopList.CanvasSize = UDim2.new(0, 0, 0, 0)
	shopList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	shopList.Parent = shopFrame
	local shopLayout = Instance.new("UIListLayout")
	shopLayout.Padding = UDim.new(0, 6)
	shopLayout.Parent = shopList
	refs.shopList = shopList

	-- Your base, right side under the money panel.
	local baseFrame = Instance.new("Frame")
	baseFrame.Name = "BaseFrame"
	baseFrame.AnchorPoint = Vector2.new(1, 0)
	baseFrame.Position = UDim2.new(1, -12, 0, 100)
	baseFrame.Size = UDim2.new(0, 240, 0, 260)
	baseFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
	baseFrame.BackgroundTransparency = 0.25
	baseFrame.BorderSizePixel = 0
	baseFrame.Parent = gui
	local baseCorner = Instance.new("UICorner")
	baseCorner.CornerRadius = UDim.new(0, 10)
	baseCorner.Parent = baseFrame
	makeLabel(baseFrame, "BaseTitle", "BASEKU", UDim2.new(1, -16, 0, 28), UDim2.new(0, 8, 0, 6), 17, Color3.fromRGB(255, 220, 100))
	local baseList = Instance.new("ScrollingFrame")
	baseList.Name = "BaseList"
	baseList.Position = UDim2.new(0, 8, 0, 40)
	baseList.Size = UDim2.new(1, -16, 1, -48)
	baseList.BackgroundTransparency = 1
	baseList.ScrollBarThickness = 4
	baseList.CanvasSize = UDim2.new(0, 0, 0, 0)
	baseList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	baseList.Parent = baseFrame
	local baseLayout = Instance.new("UIListLayout")
	baseLayout.Padding = UDim.new(0, 6)
	baseLayout.Parent = baseList
	refs.baseList = baseList

	-- Action buttons, bottom right.
	refs.lockButton = makeButton(gui, "LockButton", "KUNCI BASE (60 dtk)", UDim2.new(0, 200, 0, 40), UDim2.new(1, -212, 1, -172), Color3.fromRGB(60, 120, 220))
	refs.upgradeButton = makeButton(gui, "UpgradeButton", "UPGRADE BASE", UDim2.new(0, 200, 0, 40), UDim2.new(1, -212, 1, -124), Color3.fromRGB(40, 160, 90))
	refs.rebirthButton = makeButton(gui, "RebirthButton", "REBIRTH", UDim2.new(0, 200, 0, 40), UDim2.new(1, -212, 1, -76), Color3.fromRGB(180, 60, 180))

	-- Toast, bottom centre.
	refs.toastLabel = makeLabel(gui, "ToastLabel", "", UDim2.new(0, 560, 0, 30), UDim2.new(0.5, -280, 1, -48), 17, Color3.fromRGB(255, 255, 255))
	refs.toastLabel.TextXAlignment = Enum.TextXAlignment.Center
	refs.toastLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	refs.toastLabel.BackgroundTransparency = 0.4
	refs.toastLabel.Visible = false

	-- How to play, bottom left.
	local helpLabel = makeLabel(gui, "HelpLabel", "Beli brainrot di conveyor, kumpulkan di basemu. Klik brainrot orang lain untuk mencuri. Saat tsunami, lari pulang!", UDim2.new(0, 320, 0, 60), UDim2.new(0, 12, 1, -72), 13, Color3.fromRGB(220, 230, 255))
	helpLabel.TextWrapped = true

	return refs
end

local function clearChildren(frame)
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

function ClientUI.showToast(text)
	refs.toastLabel.Text = text
	refs.toastLabel.Visible = true
	task.delay(4, function()
		refs.toastLabel.Visible = false
	end)
end

-- Redraw the whole HUD from one server snapshot.
function ClientUI.applyState(state)
	if state.cash ~= nil then
		refs.cashLabel.Text = "$" .. tostring(state.cash)
	end
	if state.income ~= nil then
		refs.incomeLabel.Text = "+$" .. tostring(state.income) .. "/detik"
	end
	if state.rebirths ~= nil then
		refs.rebirthLabel.Text = "Rebirth " .. tostring(state.rebirths) .. " (x" .. tostring(state.multiplier) .. ")  |  Base Lv " .. tostring(state.upgradeLevel)
	end
	if state.eventPhase == "warning" then
		refs.eventLabel.Text = "TSUNAMI DALAM " .. tostring(state.eventSecondsLeft) .. " DETIK - LARI PULANG!"
		refs.eventLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	elseif state.eventPhase == "wave" then
		refs.eventLabel.Text = "TSUNAMI! BERLINDUNG DI BASE!"
		refs.eventLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	else
		refs.eventLabel.Text = "Ombak tenang - tsunami dalam " .. tostring(state.eventSecondsLeft) .. " dtk"
		refs.eventLabel.TextColor3 = Color3.fromRGB(140, 210, 255)
	end
	if state.lockSecondsLeft ~= nil and state.lockSecondsLeft > 0 then
		refs.lockButton.Text = "TERKUNCI (" .. tostring(state.lockSecondsLeft) .. " dtk)"
	elseif state.lockCooldownLeft ~= nil and state.lockCooldownLeft > 0 then
		refs.lockButton.Text = "KUNCI BASE (cooldown " .. tostring(state.lockCooldownLeft) .. " dtk)"
	else
		refs.lockButton.Text = "KUNCI BASE (60 dtk)"
	end
	if state.upgradeCost ~= nil then
		refs.upgradeButton.Text = "UPGRADE BASE ($" .. tostring(state.upgradeCost) .. ")"
	end
	if state.rebirthCost ~= nil then
		refs.rebirthButton.Text = "REBIRTH ($" .. tostring(state.rebirthCost) .. ")"
	end
	-- Shop rows: one per brainrot on the belt, with a Buy button. Rebuilt
	-- only when the belt itself changes, never on a plain money tick.
	if state.belt ~= nil then
		local shopKey = listKey(state.belt, { "uid", "name", "price", "income", "mutation" })
		if shopKey ~= lastShopKey then
			lastShopKey = shopKey
			clearChildren(refs.shopList)
		if #state.belt == 0 then
			makeLabel(refs.shopList, "EmptyShop", "Conveyor kosong... brainrot baru segera datang!", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), 14, Color3.fromRGB(200, 200, 200))
		end
		for _, row in ipairs(state.belt) do
			local item = Instance.new("Frame")
			item.Size = UDim2.new(1, 0, 0, 64)
			item.BackgroundColor3 = Color3.fromRGB(40, 55, 85)
			item.BorderSizePixel = 0
			item.Parent = refs.shopList
			local itemCorner = Instance.new("UICorner")
			itemCorner.CornerRadius = UDim.new(0, 8)
			itemCorner.Parent = item
			makeLabel(item, "Name", row.name, UDim2.new(1, -90, 0, 22), UDim2.new(0, 8, 0, 4), 15, Color3.fromRGB(255, 255, 255))
			makeLabel(item, "Info", row.rarity .. " " .. row.mutation .. " - $" .. tostring(row.income) .. "/s", UDim2.new(1, -90, 0, 18), UDim2.new(0, 8, 0, 28), 13, Color3.fromRGB(180, 200, 255))
			makeLabel(item, "Price", "$" .. tostring(row.price), UDim2.new(1, -90, 0, 18), UDim2.new(0, 8, 0, 44), 13, Color3.fromRGB(120, 255, 120))
			local buy = makeButton(item, "BuyButton", "BELI", UDim2.new(0, 70, 0, 32), UDim2.new(1, -78, 0, 16), Color3.fromRGB(40, 160, 90))
			local uid = row.uid
			buy.MouseButton1Click:Connect(function()
				local ok, message = ReplicatedStorage:WaitForChild("BuyBrainrot"):InvokeServer(uid)
				if message ~= nil then
					ClientUI.showToast(message)
				end
			end)
		end
		end
	end
	-- Owned rows: name, income, a mutation re-roll button and a sell button.
	-- Rebuilt only when the collection itself changes, never on a money tick.
	if state.owned ~= nil then
		local baseKey = listKey(state.owned, { "uid", "name", "income", "mutation" })
		if baseKey ~= lastBaseKey then
			lastBaseKey = baseKey
			clearChildren(refs.baseList)
		if #state.owned == 0 then
			makeLabel(refs.baseList, "EmptyBase", "Basemu kosong. Beli brainrot pertamamu!", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), 14, Color3.fromRGB(200, 200, 200))
		end
		for _, row in ipairs(state.owned) do
			local item = Instance.new("Frame")
			item.Size = UDim2.new(1, 0, 0, 52)
			item.BackgroundColor3 = Color3.fromRGB(40, 55, 85)
			item.BorderSizePixel = 0
			item.Parent = refs.baseList
			local itemCorner = Instance.new("UICorner")
			itemCorner.CornerRadius = UDim.new(0, 8)
			itemCorner.Parent = item
			makeLabel(item, "Name", row.name, UDim2.new(1, -140, 0, 22), UDim2.new(0, 8, 0, 4), 14, Color3.fromRGB(255, 255, 255))
			makeLabel(item, "Info", row.rarity .. " " .. row.mutation .. " - $" .. tostring(row.income) .. "/s", UDim2.new(1, -140, 0, 18), UDim2.new(0, 8, 0, 26), 12, Color3.fromRGB(180, 200, 255))
			local reroll = makeButton(item, "RerollButton", "MUTASI", UDim2.new(0, 62, 0, 28), UDim2.new(1, -134, 0, 12), Color3.fromRGB(150, 80, 200))
			local sell = makeButton(item, "SellButton", "JUAL", UDim2.new(0, 56, 0, 28), UDim2.new(1, -64, 0, 12), Color3.fromRGB(200, 90, 60))
			local uid = row.uid
			reroll.MouseButton1Click:Connect(function()
				ReplicatedStorage:WaitForChild("RequestReroll"):FireServer(uid)
			end)
			sell.MouseButton1Click:Connect(function()
				ReplicatedStorage:WaitForChild("SellBrainrot"):FireServer(uid)
			end)
		end
		end
	end
end

return ClientUI
