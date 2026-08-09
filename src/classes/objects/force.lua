local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"

local Force = Instance:RegisterClass("Force", "Instance", {
    Properties = {
        Enabled = {
            type = "boolean",
            default = true,
            category = "Force",
        },

        Velocity = {
            type = "Vector3",
            default = function()
                return Vector3.new(0, 0, 0)
            end,
            category = "Force",
        },

        MaxForce = {
            type = "Vector3",
            default = function()
                return Vector3.new(
                    math.huge,
                    math.huge,
                    math.huge
                )
            end,
            category = "Force",
        },
    },
})

return Force