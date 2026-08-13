local Instance = require "src.core.instance"

local Vector3 = require "src.types.vector3"
local Color3 = require "src.types.color3"

local PointLight = Instance:RegisterClass("PointLight", "Instance", {
    Properties = {
        Color = {
            type = "Color3",
            default = function()
                return Color3.new(1, 1, 1)
            end,
            category = "PointLight",
        },

        Position = {
            type = "Vector3",
            default = function()
                return Vector3.new(0, 3, 0)
            end,
            category = "PointLight",
        },

        Enabled = {
            type = "boolean",
            default = true,
            category = "PointLight",
        },

        Range = {
            type = "number",
            default = 20,
            category = "PointLight",
        },
    },
})

return PointLight