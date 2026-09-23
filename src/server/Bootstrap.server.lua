-- First milestone: non-combat flight game foundation.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Catalog = require(Shared:WaitForChild("DroneCatalog"))
local Config = require(Shared:WaitForChild("GameConfig"))

local function setupPlayer(player)
 local coins = Instance.new("IntValue")
 coins.Name = "Coins"
 coins.Value = Config.STARTING_COINS
 coins.Parent = player
 local selected = Instance.new("StringValue")
 selected.Name = "SelectedDrone"
 selected.Value = Config.STARTER_DRONE
 selected.Parent = player
 assert(Catalog[selected.Value], "Starter drone missing from catalog")
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in Players:GetPlayers() do
 setupPlayer(player)
end
