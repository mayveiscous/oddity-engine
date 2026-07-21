local Instance = require("src.core.instance")
local Vector3 = require("src.types.vector3")

local Camera = require("src.classes.camera")
local Lighting = require("src.classes.lighting")
local Players = require("src.classes.players")
local Player = require("src.classes.player")
local Workspace = require("src.classes.workspace")
local Sky = require("src.classes.sky")

-- ! cant require runservice because runservice requires game
local services = {
    InputService = require("src.classes.inputservice"),
    Lighting = require("src.classes.lighting"),
    SelectionService = require("src.classes.selectionservice"),
}

local Game = {}
Game.Workspace = Instance.new("Workspace")

Game.CurrentCamera = Instance.new("Camera")
Game.CurrentCamera.Position = Vector3.new(2, 2, 4)
Game.CurrentCamera.LookAt = Vector3.new(0, 0, 0)

Game.Lighting = Instance.new("Lighting")
Game.Lighting.Sky = Instance.new("Sky")
Game.Lighting.Sky.Texture = "" -- texture id here

Game.Players = Instance.new("Players")
Game.Players.Players["mayveiscous"] = Instance.new("Player")

function Game:GetService(name)
    if services[name] ~= nil then
        return services[name]
    end

    if name == "RunService" then
        local rs = require("src.classes.runservice")
        services[name] = rs
        return rs
    end

    if name == "Workspace" then
        return Game.Workspace
    end

    if name == "Players" then
        return Game.Players
    end

    error(("Service '%s' does not exist."):format(name), 2)
end

return Game