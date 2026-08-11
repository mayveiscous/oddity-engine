local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"
local SelectionService = require "src.classes.services.selectionservice"
local Game = require "src.game"

local InsertObject = {}

local nameCounters = {}

local function nextName(parent, base)
    if not parent:FindFirstChild(base) then
        return base
    end

    local count = 2

    while parent:FindFirstChild(base .. tostring(count)) do
        count = count + 1
    end

    return base .. tostring(count)
end

local function defaultPosition()
    local sel = SelectionService.current
    if sel and sel.Position then
        return sel.Position + Vector3.new(3, 0, 0)
    end
    return Vector3.new(0, 5, 0)
end

InsertObject.Catalog = {
    { label = "Block",      className = "Block",  shape = "Block" },
    { label = "Wedge",      className = "Block",  shape = "Wedge" },
    { label = "Sphere",     className = "Block",  shape = "Sphere" },
    { label = "Spawn",      className = "Spawn" },
    { label = "Folder",     className = "Folder" },
    { label = "Model",      className = "Model" },
    { label = "PointLight", className = "PointLight" },
    { label = "SpotLight",  className = "SpotLight" },
    { label = "LuaScript",  className = "LuaScript" },
    { label = "SinkScript", className = "SinkScript"},
    { label = "Module",     className = "Module" },
    { label = "Audio",      className = "Audio" },
}

function InsertObject.CreateEntry(entry, parent)
    if type(entry) == "string" then
        entry = { label = entry, className = entry }
    end

    parent = parent or Game.Workspace

    local inst = Instance.new(entry.className)
    inst.Name = nextName(parent, entry.label)
    inst.Parent = parent
    
    if entry.shape then
        inst.Shape = entry.shape
    end

    if inst.Position ~= nil then
        inst.Position = defaultPosition()
    end

    SelectionService.Select(inst)
    return inst
end

function InsertObject.Block(shape)
    return InsertObject.CreateEntry({ label = shape or "Block", className = "Block", shape = shape }, Game.Workspace)
end

function InsertObject.Spawn()
    return InsertObject.CreateEntry({ label = "Spawn", className = "Spawn" }, Game.Workspace)
end

function InsertObject.Folder()
    return InsertObject.CreateEntry({ label = "Folder", className = "Folder" }, Game.Workspace)
end

return InsertObject