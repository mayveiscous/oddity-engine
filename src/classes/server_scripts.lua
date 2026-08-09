local Instance = require "src.core.instance"

local ServerScripts = Instance:RegisterClass("ServerScripts", "Instance")

ServerScripts.PropertyTypes = {
    CanBeDeleted = "boolean",
    CanReparent = "boolean",
    BlockScripts = "boolean",
}

ServerScripts.Defaults = function() 
    return {
        CanBeDeleted = false,
        CanReparent = false,
        BlockScripts = false,
    }
end

return ServerScripts