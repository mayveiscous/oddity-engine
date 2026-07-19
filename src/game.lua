local Instance = require("src.core.instance")
local Vector3 = require("src.types.vector3")

local Camera = require("src.classes.camera")
local Lighting = require("src.classes.lighting")
local Players = require("src.classes.players")
local Player = require("src.classes.player")
local Workspace = require("src.classes.workspace")


local Game = {}
Game.Workspace = Instance.new("Workspace")

Game.CurrentCamera = Instance.new("Camera")
Game.CurrentCamera.Position = Vector3.new(2, 2, 4)
Game.CurrentCamera.LookAt = Vector3.new(0, 0, 0)

Game.Lighting = Instance.new("Lighting")
Game.Players = Instance.new("Players")
Game.Players.Players["mayveiscous"] = Instance.new("Player")

return Game