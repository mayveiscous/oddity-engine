local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"

local Motor = Instance:RegisterClass("Motor", "Instance", {
    Properties = {
        Part0 = {
            type = "Instance",
            default = nil,
            category = "Motor",
        },

        Part1 = {
            type = "Instance",
            default = nil,
            category = "Motor",
        },

        C0 = {
            type = "Vector3",
            default = function()
                return Vector3.zero()
            end,
            category = "Motor",
        },

        C1 = {
            type = "Vector3",
            default = function()
                return Vector3.zero()
            end,
            category = "Motor",
        },

        RestRotation = {
            type = "Vector3",
            default = function()
                return Vector3.zero()
            end,
            category = "Motor",
        },

        CurrentRotation = {
            type = "Vector3",
            default = function()
                return Vector3.zero()
            end,
            category = "Motor",
        },
    },
})

return Motor