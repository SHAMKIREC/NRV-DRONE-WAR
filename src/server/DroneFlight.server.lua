-- Server-owned, non-combat training drone. Client requests are validated.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DroneCatalog"))

local remote = Instance.new("RemoteEvent")
remote.Name = "DroneFlight"
remote.Parent = ReplicatedStorage
local drones = {}
local inputs = {}

local function destroyDrone(player)
 local state = drones[player]
 if state then state.model:Destroy() end
 drones[player] = nil
 inputs[player] = nil
 remote:FireClient(player, "Stopped")
end

local function spawnDrone(player)
 destroyDrone(player)
 local selected = player:FindFirstChild("SelectedDrone")
 local config = selected and Catalog[selected.Value] or Catalog.Scout
 local character = player.Character
 local root = character and character:FindFirstChild("HumanoidRootPart")
 if not root then return end
 local model = Instance.new("Model")
 model.Name = "NRV_" .. player.UserId
 local body = Instance.new("Part")
 body.Name = "Body"
 body.Size = Vector3.new(3, 0.55, 2.4)
 body.Material = Enum.Material.Metal
 body.Color = config.color
 body.Anchored = true
 body.CanCollide = false
 body.CFrame = root.CFrame * CFrame.new(0, 8, -12)
 body.Parent = model
 model.PrimaryPart = body
 for _, offset in ipairs({Vector3.new(-2, 0, -1.5), Vector3.new(2, 0, -1.5), Vector3.new(-2, 0, 1.5), Vector3.new(2, 0, 1.5)}) do
  local arm = Instance.new("Part")
  arm.Name = "Rotor"
  arm.Size = Vector3.new(1.45, 0.14, 1.45)
  arm.Shape = Enum.PartType.Cylinder
  arm.Anchored = true
  arm.CanCollide = false
  arm.Material = Enum.Material.Neon
  arm.Color = Color3.fromRGB(33, 38, 45)
  arm.CFrame = body.CFrame * CFrame.new(offset)
  arm.Parent = model
 end
 model.Parent = workspace
 drones[player] = {model = model, config = config, yaw = 0, position = body.Position}
 inputs[player] = {forward = 0, turn = 0, rise = 0}
 remote:FireClient(player, "Started", model)
end

remote.OnServerEvent:Connect(function(player, action, payload)
 if action == "Spawn" then
  if not drones[player] then spawnDrone(player) end
 elseif action == "Stop" then
  if drones[player] then destroyDrone(player) end
 elseif action == "Input" and drones[player] and typeof(payload) == "table" then
  local function axis(value)
   if typeof(value) ~= "number" or value ~= value then return 0 end
   return math.clamp(value, -1, 1)
  end
  inputs[player] = {forward = axis(payload.forward), turn = axis(payload.turn), rise = axis(payload.rise)}
 end
end)

RunService.Heartbeat:Connect(function(dt)
 dt = math.min(dt, 0.08)
 for player, state in pairs(drones) do
  if not player.Parent or not state.model.Parent then
   if player.Parent then destroyDrone(player) else state.model:Destroy(); drones[player] = nil; inputs[player] = nil end
  else
   local input = inputs[player]
   local speed = 22 + state.config.speed * 0.32
   state.yaw += input.turn * dt * (1.4 + state.config.handling / 110)
   local rotation = CFrame.Angles(0, state.yaw, 0)
   local delta = rotation.LookVector * input.forward * speed * dt + Vector3.new(0, input.rise * speed * 0.55 * dt, 0)
   state.position += delta
   state.position = Vector3.new(math.clamp(state.position.X, -155, 155), math.clamp(state.position.Y, 3, 95), math.clamp(state.position.Z, -155, 155))
   state.model:PivotTo(CFrame.new(state.position) * rotation)
  end
 end
end)
Players.PlayerRemoving:Connect(function(player)
 if drones[player] then destroyDrone(player) end
end)
