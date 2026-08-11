local Instance = require "src.core.instance"

local ClientScripts = Instance:RegisterClass("ClientScripts", "Instance", {
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

        BlockScripts = {
            type = "boolean",
            default = false,
            category = "Hidden"
        },

        CanReparent = {
            type = "boolean",
            default = false,
            category = "Hidden",
        },

        IsCoreService = {
            type = "boolean",
            default = true,
            category = "Hidden",
        },
    },
})

return ClientScripts
