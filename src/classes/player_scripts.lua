local Instance = require "src.core.instance"

local PlayerScripts = Instance:RegisterClass("PlayerScripts", "Service", {
    Properties = {
        BlockScripts = {
            type = "boolean",
            default = false,
            category = "Hidden"
        },

        ShowInExplorer = {
            type = "boolean",
            default = true,
            category = "Hidden"
        },
    },
})

return PlayerScripts