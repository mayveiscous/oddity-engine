local Instance = require "src.core.instance"

local ServerStorage = Instance:RegisterClass("ServerStorage", "Instance")

ServerStorage.PropertyTypes = {
    CanBeDeleted = "boolean",
    CanReparent = "boolean",
    BlockScripts = "boolean",
}

ServerStorage.Defaults = function() 
    return {
        CanBeDeleted = false,
        CanReparent = false,
        BlockScripts = true,
    }
end

return ServerStorage