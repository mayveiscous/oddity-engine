local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"
local Color3 = require "src.types.color3"

local Lighting = Instance:RegisterClass("Lighting", "Instance")

Lighting.PropertyTypes = {
    Direction = "Vector3",
    Color = "Color3",
    Sky = "Instance",
}

Lighting.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent",
    },

    Lighting = {
        "Sky",
        "Color",
        "Direction",
    },
}

Lighting.Defaults = function()
    return {
        Direction = Vector3.new(-0.5, -1.0, -0.3),
        Color = Color3.new(1, 1, 1),
        Sky = nil,
    }
end

return Lighting