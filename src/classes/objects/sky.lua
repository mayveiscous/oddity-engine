local Instance = require "src.core.instance"

local Color3 = require "src.types.color3"

local Sky = Instance:RegisterClass("Sky", "Instance", {
    Properties = {
        Texture = {
            type = "string",
            default = "",
            category = "Appearance",
        },

        TopColor = {
            type = "Color3",
            default = function()
                return Color3.new(0.25, 0.45, 0.85)
            end,
            category = "Appearance",
        },

        HorizonColor = {
            type = "Color3",
            default = function()
                return Color3.new(0.75, 0.85, 0.95)
            end,
            category = "Appearance",
        },
    },
})

return Sky