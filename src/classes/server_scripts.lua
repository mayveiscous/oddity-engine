local Instance = require "src.core.instance"

local ServerScripts = Instance:RegisterClass("ServerScripts", "Instance", {
    Properties = {
        CanBeDeleted = {
            type = "boolean",
            default = false,
            category = "Hidden",
        },

        CanRename = {
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

return ServerScripts