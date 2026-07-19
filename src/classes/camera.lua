local Instance = require("src.core.instance")
local Vector3 = require("src.types.vector3")

local Camera = Instance:RegisterClass("Camera", "Instance")

Camera.PropertyTypes = {
    Position = "Vector3",
    LookAt = "Vector3",
}

Camera.Defaults = function()
    return {
        Position = Vector3.new(0, 0, 3),
        LookAt = Vector3.new(0, 0, 0),
    }
end

return Camera