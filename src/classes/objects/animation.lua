local Instance = require "src.core.instance"

local Animation = Instance:RegisterClass("Animation", "Instance", {
    Properties = {
        Length = {
            type = "number",
            default = 1.0,
            category = "Animation",
        },

        Tracks = {
            type = "table",
            default = function()
                return {}
            end,
            category = "Animation",
        },

        Looped = {
            type = "boolean",
            default = true,
            category = "Animation",
        },
    },
})

return Animation