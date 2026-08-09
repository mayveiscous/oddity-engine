local Instance = require "src.core.instance"

local Vector3 = require "src.types.vector3"

local Weld = Instance:RegisterClass("Weld", "Instance", {
    Properties = {
        Position = {
            type = "Vector3",
            default = function()
                return Vector3.new(0, 0, 0)
            end,
            category = "Weld",
        },

        Enabled = {
            type = "boolean",
            default = true,
            category = "Weld",
        },
    },
})

return Weld