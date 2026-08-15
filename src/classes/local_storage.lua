local Instance = require "src.core.instance"

local LocalStorage = Instance:RegisterClass("LocalStorage", "Service", {
    Properties = {
        BlockScripts = {
            type = "boolean",
            default = true,
            category = "Hidden",
        },

        ShowInExplorer = {
            type = "boolean",
            default = true,
            category = "Hidden"
        },
    },
})

return LocalStorage