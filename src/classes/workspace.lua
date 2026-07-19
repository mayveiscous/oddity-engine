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

return Workspace