local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"

local Camera = require "src.classes.camera"
local Lighting = require "src.classes.lighting"
local Players = require "src.classes.players"
local Player = require "src.classes.player"
local Workspace = require "src.classes.workspace"
local Sky = require "src.classes.sky"

local function createDefaultModules(player)
    
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
createDefaultModules(Game.Players.Players["mayveiscous"])


function Game:GetService(name)
    if name == "RunService" then
        return require "src.classes.runservice"
    elseif name == "InputService" then
        return require "src.classes.inputservice"
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