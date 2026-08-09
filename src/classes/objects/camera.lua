local Instance = require "src.core.instance"

local Vector3 = require "src.types.vector3"
local graphics = require "graphics"

local Camera = Instance:RegisterClass("Camera", "Instance", {
    Properties = {
        Position = {
            type = "Vector3",
            default = function()
                return Vector3.new(10, 4, 10)
            end,
            category = "Transform",
        },

        LookAt = {
            type = "Vector3",
            default = function()
                return Vector3.new(0, 0, 0)
            end,
            category = "Transform",
        },
    },
})

function Camera:ScreenPointToRay(x, y)
    local ox, oy, oz, dx, dy, dz =
        graphics.screenPointToRay(x, y)

    return {
        Origin = Vector3.new(ox, oy, oz),
        Direction = Vector3.new(dx, dy, dz),
    }
end

return Camera