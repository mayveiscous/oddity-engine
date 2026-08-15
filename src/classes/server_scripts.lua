local Instance = require "src.core.instance"

local ServerScripts = Instance:RegisterClass("ServerScripts", "Service", {
    Properties = {
        ShowInExplorer = {
            type = "boolean",
            default = true,
            category = "Hidden"
        },

        BlockScripts = {
            type = "boolean",
            default = false,
            category = "Hidden"
        },
    },
})

return ServerScripts