-- init.client: Pinisi Brainrot Bay's client entry point.
-- Builds the HUD, listens for the server's state snapshots and toasts,
-- and wires the Lock, Upgrade and Rebirth buttons to their remotes.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientUI = require(script.Parent.ClientUI)

local player = Players.LocalPlayer

local refs = ClientUI.build()

local ClientUpdate = ReplicatedStorage:WaitForChild("ClientUpdate")
local LockBase = ReplicatedStorage:WaitForChild("LockBase")
local RequestRebirth = ReplicatedStorage:WaitForChild("RequestRebirth")
local BuyUpgrade = ReplicatedStorage:WaitForChild("BuyUpgrade")

ClientUpdate.OnClientEvent:Connect(function(message)
	if message.type == "notify" then
		ClientUI.showToast(message.text)
	elseif message.type == "state" then
		ClientUI.applyState(message)
	end
end)

refs.lockButton.MouseButton1Click:Connect(function()
	LockBase:FireServer()
end)

refs.upgradeButton.MouseButton1Click:Connect(function()
	BuyUpgrade:FireServer()
end)

refs.rebirthButton.MouseButton1Click:Connect(function()
	RequestRebirth:FireServer()
end)

print("Pinisi Brainrot Bay client ready.")
