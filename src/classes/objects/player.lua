local Instance = require "src.core.instance"

local Player = Instance:RegisterClass("Player", "Instance", {
    Properties = {
        Character = {
            type = "Instance",
            default = nil,
            category = "Player",
        },

        UserId = {
            type = "number",
            default = 0,
            category = "Player",
        },
    },
})

return Player