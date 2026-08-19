local Instance = require "src.core.instance"
local Internal = require "src.core.internal"
local Vector3 = require "src.types.vector3"

local Camera = require "src.classes.objects.camera"
local Lighting = require "src.classes.lighting"
local Players = require "src.classes.players"
local Workspace = require "src.classes.workspace"
local LocalStorage = require "src.classes.local_storage"
local ServerStorage = require "src.classes.server_storage"
local ServerScripts = require "src.classes.server_scripts"
local PlayerScripts = require "src.classes.player_scripts"
local SoundStorage = require "src.classes.sound_storage"
local DataService = require "src.classes.data_service"
local Player = require "src.classes.objects.player"
local Sky = require "src.classes.objects.sky"

local GameClass = require "src.classes.game"

local defaultModuleSources = require "src.data.default_modules"

local function createDefaultModules(player)
    local characterController = Instance.new("LuaScript")
    characterController.Name = "CharacterController"
    characterController.Source = defaultModuleSources.CharacterController
    Internal.SetProperty(characterController, "CoreScript", true)
    characterController.Parent = player:FindFirstChild("Modules")

    local cameraController = Instance.new("LuaScript")
    cameraController.Name = "CameraController"
    cameraController.Source = defaultModuleSources.CameraController
    Internal.SetProperty(cameraController, "CoreScript", true)
    cameraController.Parent = player:FindFirstChild("Modules")
end

local function createCore(className, parent)
    local instance = Instance.new(className)
    instance:AddTag("COREcantDelete")
    instance.Parent = parent
    return instance
end

local Game = Instance.new("Game")

Game.Workspace = createCore("Workspace", Game)
Game.CurrentCamera = createCore("Camera", Game)
Game.Lighting = createCore("Lighting", Game)
Game.Players = createCore("Players", Game)
Game.LocalStorage = createCore("LocalStorage", Game)
Game.ServerStorage = createCore("ServerStorage", Game)
Game.ServerScripts = createCore("ServerScripts", Game)
Game.PlayerScripts = createCore("PlayerScripts", Game)
Game.ClientScripts = createCore("ClientScripts", Game)
Game.SoundStorage = createCore("SoundStorage", Game)
Game.DataService = createCore("DataService", Game)

Game.Lighting.Sky = createCore("Sky", Game.Lighting)

local player = Instance.new("Player")
player.Name = "mayveiscous"
player.Parent = Game.Players

local modules = Instance.new("Folder")
modules.Name = "Modules"
modules.Parent = player

Game.Players.LocalPlayer = player
createDefaultModules(player)

function Game:GetService(name)
    if name == "RunService" then
        return require "src.classes.services.runservice"
    elseif name == "InputService" then
        return require "src.classes.services.inputservice"
    end

    if name == "Workspace" then
        return Game.Workspace
    end

    if name == "Players" then
        return Game.Players
    end

    if name == "Lighting" then
        return Game.Lighting
    end

    if name == "LocalStorage" then
        return Game.LocalStorage
    end

    if name == "ServerStorage" then
        return Game.ServerStorage
    end

    if name == "ServerScripts" then
        return Game.ServerScripts
    end

    if name == "DataService" then
        return Game.DataService
    end

    if name == "ClientScripts" then
        return Game.ClientScripts
    end

    if name == "SoundStorage" then
        return Game.SoundStorage
    end

    error(("Service '%s' does not exist."):format(name), 2)
end

local originalParents = {}

function Game.beginPlaytest()
    for _, script in ipairs(Game.PlayerScripts:GetDescendants()) do
        if script:IsA("LuaScript") or script:IsA("SinkScript") or script:IsA("Folder") then
            if not Game.Players.LocalPlayer then goto continue end
            originalParents[script] = script.Parent
            script.Parent = Game.Players.LocalPlayer:FindFirstChild("Modules")
        end

        ::continue::
    end
end

function Game.stopPlaytest()
    if not Game.Players.LocalPlayer then goto continue end

    for _, script in ipairs(Game.Players.LocalPlayer:FindFirstChild("Modules"):GetDescendants()) do
        if not script.CoreScript then
            script.Parent = originalParents[script]
        end
    end

    ::continue::
end

return Game