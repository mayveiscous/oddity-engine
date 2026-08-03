local Instance = require "src.core.instance"
local Game = require "src.game"
local DefaultRig = require "src.rig.default_rig"
local Vector3 = require "src.types.vector3"
local Color3 = require "src.types.color3"

local Baseplate = require "src.create-runtime.baseplate"

local char_cam = require "src.scripting.default_modules.character_camera"
local char_controller = require "src.scripting.default_modules.character_controller"
local anim_controller = require "src.scripting.default_modules.animation_controller"

local characters = {}

local function createCharacter(player)
    local spawnPos = Baseplate.getSpawnPoint()
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