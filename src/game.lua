local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"

local Camera = require "src.classes.objects.camera"
local Lighting = require "src.classes.lighting"
local Players = require "src.classes.players"
local Player = require "src.classes.objects.player"
local Workspace = require "src.classes.workspace"
local Sky = require "src.classes.objects.sky"

local defaultModuleSources = require "src.data.default_modules"

local function createDefaultModules(player)
    local characterController = Instance.new("LuaScript")
    characterController.Name = "CharacterController"
    characterController.Source = defaultModuleSources.CharacterController
    characterController.CoreScript = true
    characterController.Parent = player.Modules

    local cameraController = Instance.new("LuaScript")
    cameraController.Name = "CameraController"
    cameraController.Source = defaultModuleSources.CameraController
    cameraController.CoreScript = true
    cameraController.Parent = player.Modules
end

local Game = {}
Game.Workspace = Instance.new("Workspace")

Game.CurrentCamera = Instance.new("Camera")
Game.CurrentCamera.Position = Vector3.new(10, 4, 10)
Game.CurrentCamera.LookAt = Vector3.new(0, 0, 0)

Game.Lighting = Instance.new("Lighting")
Game.Lighting.Sky = Instance.new("Sky")
Game.Lighting.Sky.Texture = "" -- texture id here

Game.Players = Instance.new("Players")
Game.Players.Players["mayveiscous"] = Instance.new("Player")
Game.Players.Players["mayveiscous"].Modules = Instance.new("Folder")
Game.Players.Players["mayveiscous"].Modules.Name = "Modules"
createDefaultModules(Game.Players.Players["mayveiscous"])

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

    error(("Service '%s' does not exist."):format(name), 2)
end

return Game