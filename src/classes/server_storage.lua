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

        IsCoreService = {
            type = "boolean",
            default = true,
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