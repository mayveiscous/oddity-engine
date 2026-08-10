local Instance = require "src.core.instance"

local ServerStorage = Instance:RegisterClass("ServerStorage", "Instance", {
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

        CanRename = {
            type = "boolean",
            default = false,
            category = "Hidden",
        },

        BlockScripts = {
            type = "boolean",
            default = true,
            category = "Hidden",
        },
    },
})

return ServerStorage