local Instance = require("src.core.instance")
local Vector3 = require("src.types.vector3")

local Camera = require("src.classes.camera")
local Lighting = require("src.classes.lighting")

local Game = {}
Game.Workspace = Instance.new("Workspace")

Game.CurrentCamera = Instance.new("Camera")
Game.CurrentCamera.Position = Vector3.new(2, 2, 4)
Game.CurrentCamera.LookAt = Vector3.new(0, 0, 0)

Game.Lighting = Instance.new("Lighting")

return Game