local Instance = require "src.core.instance"

local ServerStorage = Instance:RegisterClass("ServerStorage", "Service", {
    Properties = {
        ShowInExplorer = {
            type = "boolean",
            default = true,
            category = "Hidden"
        },

        BlockScripts = {
            type = "boolean",
            default = true,
            category = "Hidden",
        },
    },
})

return ServerStorage