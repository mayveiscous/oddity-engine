local Instance = require("src.core.instance")

local Game = require("src.game")

local Vector3 = require("src.types.vector3")
local Color3 = require("src.types.color3")

local ground = Instance.new("Block")
ground.Name = "Ground"
ground.Parent = Game.Workspace
ground.Locked = true
ground.Size = Vector3.new(100, 1, 100)
ground.Color = Color3.new(0.4, 0.16, 0.16)
ground.CanCollide = true