-- Builds a compact flight training island with no third-party assets.
local Workspace = game:GetService("Workspace")
if Workspace:FindFirstChild("NRVWorld") then return end
local world = Instance.new("Folder")
world.Name = "NRVWorld"
world.Parent = Workspace

local function part(name, size, position, color, material, parent)
 local object = Instance.new("Part")
 object.Name = name
 object.Anchored = true
 object.Size = size
 object.Position = position
 object.Color = color
 object.Material = material or Enum.Material.SmoothPlastic
 object.Parent = parent or world
 return object
end

local ground = part("TrainingGround", Vector3.new(330, 2, 330), Vector3.new(0, -2, 0), Color3.fromRGB(54, 98, 76), Enum.Material.Grass)
local pad = part("LaunchPad", Vector3.new(34, 1, 34), Vector3.new(0, -0.45, 0), Color3.fromRGB(30, 38, 49), Enum.Material.Metal)
local marker = part("PadStripe", Vector3.new(27, 0.15, 2), Vector3.new(0, 0.16, 0), Color3.fromRGB(238, 148, 51), Enum.Material.Neon)
marker.CanCollide = false

local rng = Random.new(8624)
for i = 1, 38 do
 local x, z = rng:NextNumber(-145, 145), rng:NextNumber(-145, 145)
 if math.abs(x) > 32 or math.abs(z) > 32 then
  local trunk = part("TreeTrunk", Vector3.new(2.5, 10, 2.5), Vector3.new(x, 4, z), Color3.fromRGB(85, 60, 43), Enum.Material.Wood)
  trunk.Shape = Enum.PartType.Cylinder
  local crown = part("TreeCrown", Vector3.new(10, 17, 10), Vector3.new(x, 14, z), Color3.fromRGB(30, rng:NextInteger(75, 110), 69), Enum.Material.Grass)
  crown.Shape = Enum.PartType.Ball
 end
end

for i = 1, 5 do
 local ring = Instance.new("Model")
 ring.Name = "FlightGate" .. i
 ring.Parent = world
 local x = -100 + i * 37
 local z = 55 + math.sin(i * 1.2) * 20
 local centerY = 17
 for j = 1, 12 do
  local a = j * math.pi / 6
  local segment = part("GateSegment", Vector3.new(2.2, 2.2, 2.2), Vector3.new(x + math.cos(a)*11, centerY + math.sin(a)*11, z), Color3.fromRGB(46, 199, 239), Enum.Material.Neon, ring)
  segment.Shape = Enum.PartType.Ball
  segment.CanCollide = false
 end
end
local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
if spawn then spawn.Position = Vector3.new(0, 1, -22) end
