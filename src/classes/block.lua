local Instance = require("src.core.instance")
local Vector3 = require("src.types.vector3")
local Color3 = require("src.types.color3")
local render = require("render")

local Block = Instance:RegisterClass("Block", "Instance")

Block.PropertyTypes = {
    Position = "Vector3",
    Size = "Vector3",
    Rotation = "Vector3",
    Color = "Color3",
    Transparency = "number",
    Anchored = "boolean",
    CanCollide = "boolean",
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
        _meshId = nil,
    }
end

local cubeVertices = {
    -- back face (normal: 0,0,-1)
    -0.5,-0.5,-0.5,  0,0,-1,
     0.5,-0.5,-0.5,  0,0,-1,
     0.5, 0.5,-0.5,  0,0,-1,
     0.5, 0.5,-0.5,  0,0,-1,
    -0.5, 0.5,-0.5,  0,0,-1,
    -0.5,-0.5,-0.5,  0,0,-1,

    -- front face (normal: 0,0,1)
    -0.5,-0.5, 0.5,  0,0,1,
     0.5,-0.5, 0.5,  0,0,1,
     0.5, 0.5, 0.5,  0,0,1,
     0.5, 0.5, 0.5,  0,0,1,
    -0.5, 0.5, 0.5,  0,0,1,
    -0.5,-0.5, 0.5,  0,0,1,

    -- left face (normal: -1,0,0)
    -0.5, 0.5, 0.5,  -1,0,0,
    -0.5, 0.5,-0.5,  -1,0,0,
    -0.5,-0.5,-0.5,  -1,0,0,
    -0.5,-0.5,-0.5,  -1,0,0,
    -0.5,-0.5, 0.5,  -1,0,0,
    -0.5, 0.5, 0.5,  -1,0,0,

    -- right face (normal: 1,0,0)
     0.5, 0.5, 0.5,  1,0,0,
     0.5, 0.5,-0.5,  1,0,0,
     0.5,-0.5,-0.5,  1,0,0,
     0.5,-0.5,-0.5,  1,0,0,
     0.5,-0.5, 0.5,  1,0,0,
     0.5, 0.5, 0.5,  1,0,0,

    -- bottom face (normal: 0,-1,0)
    -0.5,-0.5,-0.5,  0,-1,0,
     0.5,-0.5,-0.5,  0,-1,0,
     0.5,-0.5, 0.5,  0,-1,0,
     0.5,-0.5, 0.5,  0,-1,0,
    -0.5,-0.5, 0.5,  0,-1,0,
    -0.5,-0.5,-0.5,  0,-1,0,

    -- top face (normal: 0,1,0)
    -0.5, 0.5,-0.5,  0,1,0,
     0.5, 0.5,-0.5,  0,1,0,
     0.5, 0.5, 0.5,  0,1,0,
     0.5, 0.5, 0.5,  0,1,0,
    -0.5, 0.5, 0.5,  0,1,0,
    -0.5, 0.5,-0.5,  0,1,0,
}

function Block:Init()
    self:EnsureMesh()
end

function Block:EnsureMesh()
    if self._meshId then
        return self._meshId
    end

    local ok, meshId = pcall(function()
        return render.createMesh(cubeVertices)
    end)

    if ok then
        self._meshId = meshId
    end

    return self._meshId
end

return Block