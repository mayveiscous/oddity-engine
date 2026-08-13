local Instance = require "src.core.instance"

local Vector3 = require "src.types.vector3"
local Color3 = require "src.types.color3"

local SpotLight = Instance:RegisterClass("SpotLight", "Instance", {
    Properties = {
        Color = {
            type = "Color3",
            default = function()
                return Color3.new(1, 1, 1)
            end,
            category = "SpotLight",
        },

        Position = {
            type = "Vector3",
            default = function()
                return Vector3.new(0, 5, 0)
            end,
            category = "SpotLight",
        },

        Direction = {
            type = "Vector3",
            default = function()
                return Vector3.new(0, -1, 0)
            end,
            category = "SpotLight",
        },

        Enabled = {
            type = "boolean",
            default = true,
            category = "SpotLight",
        },

        InnerAngle = {
            type = "number",
            default = 12.5,
            category = "SpotLight",
        },

        OuterAngle = {
            type = "number",
            default = 17.5,
            category = "SpotLight",
        },

        Range = {
            type = "number",
            default = 20,
            category = "SpotLight",
        },
    },
})

return SpotLight