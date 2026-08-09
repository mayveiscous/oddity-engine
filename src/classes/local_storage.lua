local Instance = require "src.core.instance"

local LocalStorage = Instance:RegisterClass("LocalStorage", "Instance")

LocalStorage.PropertyTypes = {
    CanBeDeleted = "boolean",
    CanReparent = "boolean",
    BlockScripts = "boolean",
}

LocalStorage.Defaults = function() 
    return {
        CanBeDeleted = false,
        CanReparent = false,
        BlockScripts = true,
    }
end

return LocalStorage