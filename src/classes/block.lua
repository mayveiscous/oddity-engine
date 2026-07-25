local Instance = require("src.core.instance")

local Vector3 = require("src.types.vector3")
local Color3 = require("src.types.color3")

local Shapes = require("src.render.shapes")
local graphics = require("graphics")

local Block = Instance:RegisterClass("Block", "Instance")

Block.PropertyTypes = {
    Position = "Vector3",
    Size = "Vector3",
    Rotation = "Vector3",
    Color = "Color3",
    Transparency = "number",
    Anchored = "boolean",
    Locked = "boolean",
    CanCollide = "boolean",
    Shape = "string",
    Material = "string",
}

Block.Defaults = function()
    return {
        Position = Vector3.new(0, 0, 0),
        Rotation = Vector3.new(0, 0, 0),
        Size = Vector3.new(1, 1, 1),
        Color = Color3.new(1, 0.5, 0.2),
        Anchored = false,
        CanCollide = true,
        Transparency = 0,
        Locked = false,
        Shape = "Block",
        Material = "Plastic",
        _meshId = nil,
    }
end

Block.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent"
    },

    Transform = {
        "Size",
        "Position",
        "Rotation"
    },

    Appearance = {
        "Color",
        "Material"
    },

    Physics = {
        "Anchored",
        "CanCollide",
    },
}

function Block:Init()
    
end

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