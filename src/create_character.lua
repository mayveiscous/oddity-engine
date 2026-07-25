local Instance = require("src.core.instance")
local Game = require("src.game")
local DefaultRig = require("src.rig.default_rig")
local Vector3 = require("src.types.vector3")
local Color3 = require("src.types.color3")

local char_cam = require("src.scripting.default_modules.character_camera")
local char_controller = require("src.scripting.default_modules.character_controller")
local anim_controller = require("src.scripting.default_modules.animation_controller")

local ground = Instance.new("Block")
ground.Name = "Ground"
ground.Parent = Game.Workspace
ground.Locked = true
ground.Position = Vector3.new(0, 0, 0)
ground.Size = Vector3.new(100, 1, 100)
ground.Color = Color3.new(0.4, 0.16, 0.16)

local spawn = Instance.new("Spawn")
spawn.Name = "SpawnPoint"
spawn.Parent = Game.Workspace
spawn.Position = Vector3.new(0, 0.5, 0)
spawn.Size = Vector3.new(4, 1, 4)
spawn.Color = Color3.new(0.2, 0.6, 0.9)
spawn.Transparency = 0.5

local characters = {}

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
    local ch = DefaultRig.Create(Game.Workspace, spawnPos, player.Name)

    player.Character = ch
    char_cam.Attach(ch.RootPart)
    char_controller.Attach(ch)
    anim_controller.Attach(ch)
    ch.RootPart.Position = Vector3.new(spawnPos.X, spawnPos.Y + 25, spawnPos.Z)
    characters[player.Name] = ch

    return ch
end

local function getCharacter(name)
    return characters[name]
end

local CreateCharacter = {
    createCharacter = createCharacter,
    getCharacter = getCharacter,
}

return CreateCharacter