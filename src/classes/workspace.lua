local Instance = require("src.core.instance")

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

return Workspace