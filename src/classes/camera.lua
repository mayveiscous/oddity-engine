local Instance = require("src.core.instance")
local Vector3 = require("src.types.vector3")

local graphics = require("graphics")

local Camera = Instance:RegisterClass("Camera", "Instance")

Camera.PropertyTypes = {
    Position = "Vector3",
    LookAt = "Vector3",
}

Camera.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent",
    },
    Transform = {
        "Position",
        "LookAt",
    }
}

Camera.Defaults = function()
    return {
        Position = Vector3.new(0, 0, 3),
        LookAt = Vector3.new(0, 0, 0),
    }
end

function Camera:ScreenPointToRay(x, y)
    local ox, oy, oz, dx, dy, dz =
        graphics.screenPointToRay(x, y)

    return {
        Origin = Vector3.new(ox, oy, oz),
        Direction = Vector3.new(dx, dy, dz),
    }
end

return Camera