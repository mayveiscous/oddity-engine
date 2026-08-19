local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"
local Color3 = require "src.types.color3"
local Enum = require "src.types.enum"

local game = require "src.game"

local base = Instance.new("Block")
base.Name = "Baseplate"
base.Size = Vector3.new(100, 4, 100)
base.Color = Color3.new(120, 100, 100)
base.Position = Vector3.new(0, 0, 0)

base.Locked = true
base.Anchored = true 
base.CanCollide = true 

base.Material = "Plastic"
base.Parent = game.Workspace

local spawn = Instance.new("Spawn")
spawn.Name = "SpawnPoint"
spawn.Size = Vector3.new(4, 1, 4)
spawn.Position = Vector3.new(0, 2.5, 0)
spawn.Color = Color3.new(100, 100, 150)

spawn.Anchored = true
spawn.CanCollide = true
spawn.Material = "Plastic"
spawn.Parent = game.Workspace

local spawnTexture = Instance.new("Texture")
spawnTexture.Face = Enum.Faces.Top
spawnTexture.Image = "Special"
spawnTexture.Parent = spawn

local function getSpawnPoint()
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Spawn") and obj.Enabled then
            return obj.Position
        end
    end
    return Vector3.new(0, 0, 0)
end

return { getSpawnPoint = getSpawnPoint }