local Instance = require "src.core.instance"

local Players = Instance:RegisterClass("Players", "Service", {
    Properties = {
        LocalPlayer = {
            type = "Instance",
            default = nil,
            category = "Player",
        },

        ShowInExplorer = {
            type = "boolean",
            default = true,
            category = "Hidden"
        },
    },
})

return Players