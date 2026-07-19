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


local function createCharacter(player)
    local name = player._state.Name

    local ch = Instance.new("Character")
    ch.Name = name
    ch.Parent = Game.Workspace
    
    local torso = Instance.new("Block")
    torso.Parent = Game.Workspace
    torso.Size = Vector3.new(2, 3, 1)

    local upperLeg = Instance.new("Block")
    upperLeg.Parent = Game.Workspace
    upperLeg.Size = Vector3.new(0.8, 2, 0.8)

    local hip = Instance.new("Motor")
    hip.Part0 = torso
    hip.Part1 = upperLeg
    hip.C0 = Vector3.new(-0.5, -1.5, 0)

    player._state.Character = ch
end

for _, player in pairs(Game.Players.Players) do
    -- createCharacter(player)
end