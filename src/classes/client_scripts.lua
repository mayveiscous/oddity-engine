local Instance = require "src.core.instance"

local ClientScripts = Instance:RegisterClass("ClientScripts", "Service", {
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
        }
    },
})

return ClientScripts
