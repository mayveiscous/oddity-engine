local Instance = require("src.core.instance")

local Players = Instance:RegisterClass("Players", "Instance")

Players.PropertyTypes = {
    CanBeDeleted = "boolean",
    CanReparent = "boolean",
}

Players.Defaults = function()
    return {
        CanBeDeleted = false,
        CanReparent = false,
        Players = {},
    }
end

return Players