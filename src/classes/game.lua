local Instance = require "src.core.instance"

local Game = Instance:RegisterClass("Game", "Service", {
    Properties = {
        ShowInExplorer = {
            type = "boolean",
            default = true,
            category = "Hidden"
        },
    },
})

return Game