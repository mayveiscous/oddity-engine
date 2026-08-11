local Instance = require "src.core.instance"

local Vector3 = require "src.types.vector3"
local Color3 = require "src.types.color3"

local Shapes = require "src.render.shapes"
local graphics = require "oddity.graphics"

local Block = Instance:RegisterClass("Block", "Instance", {
    Properties = {
        Position = {
            type = "Vector3",
            default = function()
                return Vector3.new(0, 0, 0)
            end,
            category = "Transform",
        },

        Size = {
            type = "Vector3",
            default = function()
                return Vector3.new(1, 1, 1)
            end,
            category = "Transform",
        },

        Rotation = {
            type = "Vector3",
            default = function()
                return Vector3.new(0, 0, 0)
            end,
            category = "Transform",
        },

        Color = {
            type = "Color3",
            default = function()
                return Color3.new(1, 0.5, 0.2)
            end,
            category = "Appearance",
        },

        Transparency = {
            type = "number",
            default = 0,
            category = "Appearance",
        },

        Anchored = {
            type = "boolean",
            default = false,
            category = "Physics",
        },

        Locked = {
            type = "boolean",
            default = false,
            category = "Physics",
        },

        CanCollide = {
            type = "boolean",
            default = true,
            category = "Physics",
        },

        Shape = {
            type = "string",
            default = "Block",
            category = "Appearance",
        },

        Material = {
            type = "string",
            default = "Plastic",
            category = "Appearance",
        },

        Texture = {
            type = "string",
            default = "",
            category = "Appearance"
        },
    }
})

local meshCache = {}

function Block:EnsureMesh()
    if self._meshId then
        return self._meshId
    end

    local shape = self.Shape or "Block"

    if meshCache[shape] then
        self._meshId = meshCache[shape]
        return self._meshId
    end

    local vertexData

    if shape == "Wedge" then
        vertexData = Shapes.Wedge
    elseif shape == "Sphere" then
        vertexData = Shapes.generateSphere()
    else
        vertexData = Shapes.Block
    end

    local ok, meshId = pcall(function()
        return graphics.createMesh(vertexData)
    end)

    if ok then
        meshCache[shape] = meshId
        self._meshId = meshId
    end

    return self._meshId
end

return Block