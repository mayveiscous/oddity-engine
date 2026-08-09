local Instance = require "src.core.instance"

local Players = Instance:RegisterClass("Players", "Instance", {
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
    },
})

return Players