local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"

local Hinge = Instance:RegisterClass("Hinge", "Instance", {
    Properties = {
        Position = {
            type = "Vector3",
            default = function()
                return Vector3.new(0, 0, 0)
            end,
            category = "Transform",
        },

        Enabled = {
            type = "boolean",
            default = true,
            category = "Physics",
        },
    },
})

return Hinge