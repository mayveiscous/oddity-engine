local Instance = require "src.core.instance"

local Game = Instance:RegisterClass("Game", "Instance", {
    Properties = {
        CanBeDeleted = {
            type = "boolean",
            default = false,
            category = "Hidden"
        },

        CanRename = {
            type = "boolean",
            default = false,
            category = "Hidden",
        },

        CanReparent = {
            type = "boolean",
            default = false,
            category = "Hidden"
        },
    },
})

return Game