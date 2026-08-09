local Instance = require "src.core.instance"

local Vector3 = require "src.types.vector3"

local Spring = Instance:RegisterClass("Spring", "Instance", {
    Properties = {
        Force = {
            type = "Vector3",
            default = function()
                return Vector3.new(0, 0, 0)
            end,
            category = "Spring",
        },

        Position = {
            type = "Vector3",
            default = function()
                return Vector3.new(0, 0, 0)
            end,
            category = "Spring",
        },
    },
})

return Spring