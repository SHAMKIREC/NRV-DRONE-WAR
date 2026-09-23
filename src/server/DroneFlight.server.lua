-- Flight training prototype; game-only aircraft.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DroneCatalog"))
local remote = Instance.new("RemoteEvent")
remote.Name = "DroneFlight"
remote.Parent = ReplicatedStorage
local drones = {}
local inputs = {}
local colors = {
 Scout = Color3.fromRGB(52, 190, 255),
 Ranger = Color3.fromRGB(255, 150, 56),
 Titan = Color3.fromRGB(177, 120, 255),
}
local function stop(player)
 local state = drones[player]
 if state then state.model:Destroy() end
 drones[player] = nil
 inputs[player] = nil
 if player.Parent then remote:FireClient(player, "Stopped") end
end
local function spawn(player)
 if drones[player] then return end
 local chosen = player:FindFirstChild("SelectedDrone")
 local name = chosen and chosen.Value or "Scout"
 local stats = Catalog[name] or Catalog.Scout
 local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not root then return end
 local model = Instance.new("Model")
 model.Name = "TrainingDrone_" .. player.UserId
 local body = Instance.new("Part")
 body.Name = "Body"
 body.Anchored = true
 body.CanCollide = false
 body.Size = Vector3.new(3, 0.5, 2)
 body.Color = colors[name] or colors.Scout
 body.Material = Enum.Material.Metal
 body.CFrame = root.CFrame * CFrame.new(0, 8, -10)
 body.Parent = model
 model.PrimaryPart = body
 for _, offset in ipairs({Vector3.new(-2, 0, -1.5), Vector3.new(2, 0, -1.5), Vector3.new(-2, 0, 1.5), Vector3.new(2, 0, 1.5)}) do
  local rotor = Instance.new("Part")
  rotor.Name = "Rotor"
  rotor.Size = Vector3.new(1.3, 0.15, 1.3)
  rotor.Shape = Enum.PartType.Cylinder
  rotor.Anchored = true
  rotor.CanCollide = false
  rotor.Color = Color3.fromRGB(35, 40, 49)
  rotor.CFrame = body.CFrame * CFrame.new(offset)
  rotor.Parent = model
 end
 model.Parent = workspace
 drones[player] = {model = model, position = body.Position, yaw = 0, stats = stats}
 inputs[player] = {forward = 0, turn = 0, rise = 0}
 remote:FireClient(player, "Started", model)
end
remote.OnServerEvent:Connect(function(player, action, input)
 if action == "Spawn" then spawn(player)
 elseif action == "Stop" then stop(player)
 elseif action == "Input" and drones[player] and typeof(input) == "table" then
  local function axis(v)
   if typeof(v) ~= "number" or v ~= v then return 0 end
   return math.clamp(v, -1, 1)
  end
  inputs[player] = {forward = axis(input.forward), turn = axis(input.turn), rise = axis(input.rise)}
 end
end)
RunService.Heartbeat:Connect(function(dt)
 dt = math.min(dt, 0.08)
 for player, state in pairs(drones) do
  if not player.Parent or not state.model.Parent then stop(player)
  else
   local input = inputs[player]
   local speed = 20 + state.stats.speed * 0.35
   state.yaw += input.turn * dt * 1.8
   local rotation = CFrame.Angles(0, state.yaw, 0)
   state.position += rotation.LookVector * input.forward * speed * dt + Vector3.new(0, input.rise * speed * dt * 0.55, 0)
   state.position = Vector3.new(math.clamp(state.position.X, -155, 155), math.clamp(state.position.Y, 3, 95), math.clamp(state.position.Z, -155, 155))
   state.model:PivotTo(CFrame.new(state.position) * rotation)
  end
 end
end)
Players.PlayerRemoving:Connect(stop)
