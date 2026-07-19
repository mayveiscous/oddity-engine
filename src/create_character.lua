local Instance = require("src.core.instance")
local Game = require("src.game")
local DefaultRig = require("src.rig.default_rig")
local Vector3 = require("src.types.vector3")
local Color3 = require("src.types.color3")

local ground = Instance.new("Block")
ground.Name = "Ground"
ground.Parent = Game.Workspace
ground.Locked = true
ground.Size = Vector3.new(100, 1, 100)
ground.Color = Color3.new(0.4, 0.16, 0.16)
ground.CanCollide = true

local spawn = Instance.new("Spawn")
spawn.Name = "SpawnPoint"
spawn.Parent = Game.Workspace
spawn.Position = Vector3.new(0, 0.5, 0)
spawn.Size = Vector3.new(4, 1, 4)
spawn.Color = Color3.new(0.2, 0.6, 0.9)
spawn.Transparency = 0.5

local function getSpawnPoint()
    for _, obj in ipairs(Game.Workspace:GetDescendants()) do
        if obj:IsA("Spawn") and obj.Enabled then
            return obj.Position
        end
    end
    return Vector3.new(0, 0, 0)
end

local function createCharacter(player)
    local spawnPos = getSpawnPoint()
    local ch = DefaultRig.Create(Game.Workspace, spawnPos)
    player.Character = ch
    return ch
end

for _, player in pairs(Game.Players.Players) do
    createCharacter(player)
end

return { createCharacter = createCharacter }