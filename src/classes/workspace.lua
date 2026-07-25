local Instance = require("src.core.instance")
local Vector3 = require("src.types.vector3")
local graphics = require("graphics")

local Workspace = Instance:RegisterClass("Workspace", "Instance")

Workspace.PropertyTypes = {
    CanBeDeleted = "boolean",
    CanReparent = "boolean",
}

Workspace.Defaults = function()
    return {
        CanBeDeleted = false,
        CanReparent = false,
    }
end

Workspace.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent",
    },
}

function Workspace:FindByUniqueId(id)
    local inst = nil

    for _, desc in ipairs(self:GetDescendants()) do
        if desc.UniqueId == id then
            inst = desc
            break
        end
    end

    return inst
end

function Workspace:Raycast(origin, direction)
    local uniqueId, distance, hx, hy, hz = graphics.raycastWorld(
        origin.X, origin.Y, origin.Z,
        direction.X, direction.Y, direction.Z
    )

    print(uniqueId, distance, hx, hy, hz)

    if not uniqueId then
        return nil
    end

    local Vector3 = require("src.types.vector3")
    local inst = self:FindByUniqueId(uniqueId)

    return {
        Instance = inst,
        Distance = distance,
        Position = Vector3.new(hx, hy, hz),
    }
end

return Workspace
