local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"

local Camera = require "src.classes.objects.camera"
local Lighting = require "src.classes.lighting"
local Players = require "src.classes.players"
local Workspace = require "src.classes.workspace"
local LocalStorage = require "src.classes.local_storage"
local ServerStorage = require "src.classes.server_storage"
local ServerScripts = require "src.classes.server_scripts"
local Player = require "src.classes.objects.player"
local Sky = require "src.classes.objects.sky"

local defaultModuleSources = require "src.data.default_modules"

local function createDefaultModules(player)
    local characterController = Instance.new("LuaScript")
    characterController.Name = "CharacterController"
    characterController.Source = defaultModuleSources.CharacterController
    characterController.CoreScript = true
    characterController.Parent = player:FindFirstChild("Modules")

    local cameraController = Instance.new("LuaScript")
    cameraController.Name = "CameraController"
    cameraController.Source = defaultModuleSources.CameraController
    cameraController.CoreScript = true
    cameraController.Parent = player:FindFirstChild("Modules")
end

local Game = {}
Game.Workspace = Instance.new("Workspace")
Game.Workspace:AddTag("COREcantDelete")

Game.CurrentCamera = Instance.new("Camera")
Game.CurrentCamera.Position = Vector3.new(10, 4, 10)
Game.CurrentCamera.LookAt = Vector3.new(0, 0, 0)
Game.CurrentCamera:AddTag("COREcantDelete")

Game.Lighting = Instance.new("Lighting")
Game.Lighting.Sky = Instance.new("Sky")
Game.Lighting.Sky.Texture = "" -- texture id here
Game.Lighting:AddTag("COREcantDelete")

Game.Players = Instance.new("Players")
Game.Players:AddTag("COREcantDelete")

Game.LocalStorage = Instance.new("LocalStorage")
Game.LocalStorage:AddTag("COREcantDelete")

Game.ServerStorage = Instance.new("ServerStorage")
Game.ServerStorage:AddTag("COREcantDelete")

Game.ServerScripts = Instance.new("ServerScripts")
Game.ServerScripts:AddTag("COREcantDelete")

local player = Instance.new("Player")
player.Name = "mayveiscous"
player.Parent = Game.Players
player:AddTag("COREcantDelete")

local modules = Instance.new("Folder")
modules.Name = "Modules"
modules.Parent = player
modules:AddTag("COREcantDelete")

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

    error(("Service '%s' does not exist."):format(name), 2)
end

return Game