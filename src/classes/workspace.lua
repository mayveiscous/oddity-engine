local Instance = require "src.core.instance"

local graphics = require "oddity.graphics"

local Workspace = Instance:RegisterClass("Workspace", "Service", {
    Properties = {
        ShowInExplorer = {
            type = "boolean",
            default = true,
            category = "Hidden"
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
    local uniqueId, distance, hx, hy, hz, nx, ny, nz =
        graphics.raycastWorld(
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
        Normal = Vector3.new(nx, ny, nz),
    }
end

return Workspace