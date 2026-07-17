local Instance = require("src.core.instance")

local Workspace = Instance:RegisterClass("Workspace", "Instance")

Workspace.Defaults = function()
    return {
        CanBeDeleted = false,
        CanReparent = false,
    }
end

return Workspace