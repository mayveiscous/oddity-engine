local Materials = require "src.render.materials"
local KeyCodes = require "src.data.keycodes"

local graphics = require "oddity.graphics"

local Color3 = require "src.types.color3"

local Enum = {}

Enum.Colors = {
    White = Color3.new(1, 1, 1),
    Black = Color3.new(0, 0, 0),
    Gray = Color3.new(0.5, 0.5, 0.5),
    LightGray = Color3.new(0.75, 0.75, 0.75),
    DarkGray = Color3.new(0.25, 0.25, 0.25),

    Red = Color3.new(1, 0, 0),
    Green = Color3.new(0, 1, 0),
    Blue = Color3.new(0, 0, 1),

    Yellow = Color3.new(1, 1, 0),
    Cyan = Color3.new(0, 1, 1),
    Magenta = Color3.new(1, 0, 1),

    Orange = Color3.new(1, 0.5, 0),
    Purple = Color3.new(0.5, 0, 1),
    Pink = Color3.new(1, 0.25, 0.5),
    Brown = Color3.new(0.6, 0.3, 0.1),

    DarkRed = Color3.new(0.5, 0, 0),
    DarkGreen = Color3.new(0, 0.5, 0),
    DarkBlue = Color3.new(0, 0, 0.5),
    DarkYellow = Color3.new(0.5, 0.5, 0),
    DarkCyan = Color3.new(0, 0.5, 0.5),
    DarkPurple = Color3.new(0.25, 0, 0.5),

    LightRed = Color3.new(1, 0.5, 0.5),
    LightGreen = Color3.new(0.5, 1, 0.5),
    LightBlue = Color3.new(0.5, 0.5, 1),
    LightYellow = Color3.new(1, 1, 0.5),
    LightCyan = Color3.new(0.5, 1, 1),
    LightPurple = Color3.new(0.75, 0.5, 1),
    LightPink = Color3.new(1, 0.5, 0.75),
}

Enum.Textures = {
    Brick = graphics.loadTexture("assets/textures/brick.png"),
    SmugFace = graphics.loadTexture("assets/textures/smug.png"),
    Special = graphics.loadTexture("assets/textures/special.png"),
}

Enum.Materials = {
    Plastic = Materials.Plastic,
    Metal = Materials.Metal,
    Wood = Materials.Wood,
    Fabric = Materials.Fabric,
    Glass = Materials.Glass,
}

Enum.KeyCodes = KeyCodes.Keys
Enum.MouseButtons = KeyCodes.MouseButtons

return Enum