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
        LookDirection = {
            type = "Vector3",
            default = function()
                return Vector3.new(0, 0, -1)
            end,
            ReadOnly = true,
            category = "Transform"
        }
    }
})

local meshCache = {}

function Block:EnsureMesh()
    local shape = self.Shape or "Block"

    -- Reuse this instance's mesh if it is still the correct shape.
    if self._meshId and self._meshShape == shape then
        return self._meshId
    end

    -- Reuse the globally cached mesh for this shape.
    if meshCache[shape] then
        self._meshId = meshCache[shape]
        self._meshShape = shape
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
        self._meshShape = shape
    end

    return self._meshId
end

function Block:GetLookDirection()
    local yaw = self.Rotation.Y
    local pitch = self.Rotation.X

    local cosPitch = math.cos(pitch)

    return Vector3.new(
        -math.sin(yaw) * cosPitch,
         math.sin(pitch),
        -math.cos(yaw) * cosPitch
    ).Unit
end

return Block