local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"

local Model = Instance:RegisterClass("Model", "Instance", {
    Properties = {
        RootPart = {
            type = "Instance",
            default = nil,
            category = "Model",
        },

        Position = {
            type = "Vector3",
            default = function()
                return Vector3.new(0, 0, 0)
            end,
            category = "Transform",
        },

        Scale = {
            type = "number",
            default = 1,
            category = "Model",
        },
    },
})

return Model