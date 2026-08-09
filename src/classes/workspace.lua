local Instance = require "src.core.instance"

local graphics = require "graphics"

local Workspace = Instance:RegisterClass("Workspace", "Instance", {
    Properties = {
        CanBeDeleted = {
            type = "boolean",
            default = false,
            category = "Hidden",
        },

        CanReparent = {
            type = "boolean",
            default = false,
            category = "Hidden",
        },
    },
})

function Workspace:FindByUniqueId(id)
    for _, desc in ipairs(self:GetDescendants()) do
        if desc.UniqueId == id then
            return desc
        end
    end

    return nil
end

function Workspace:Raycast(origin, direction)
    local uniqueId, distance, hx, hy, hz = graphics.raycastWorld(
        origin.X, origin.Y, origin.Z,
        direction.X, direction.Y, direction.Z
    )

    if not uniqueId then
        return nil
    end

    local inst = self:FindByUniqueId(uniqueId)

    return {
        Instance = inst,
        Distance = distance,
        Position = Vector3.new(hx, hy, hz),
    }
end

return Workspace