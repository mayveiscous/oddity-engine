local Instance = require "src.core.instance"

local Vector3 = require "src.types.vector3"

local Controller = Instance:RegisterClass("Controller", "Instance", {
    Properties = {
        Health = {
            type = "number",
            default = 100,
            category = "Controller",
        },

        WalkSpeed = {
            type = "number",
            default = 16,
            category = "Controller",
        },

        JumpPower = {
            type = "number",
            default = 40,
            category = "Controller",
        },

        MoveDirection = {
            type = "Vector3",
            default = function()
                return Vector3.zero()
            end,
            category = "Controller",
        },
    },
})

return Controller