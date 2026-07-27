local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"
local Color3 = require "src.types.color3"

local PointLight = Instance:RegisterClass("PointLight", "Instance")

PointLight.PropertyTypes = {
    Position = "Vector3",
    Color = "Color3",
    Enabled = "boolean",
}

PointLight.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent",
    },

    PointLight = {
        "Color",
        "Position",
        "Enabled",
    },
}

PointLight.Defaults = function()
    return {
        Position = Vector3.new(0, 3, 0),
        Color = Color3.new(1, 1, 1),
        Enabled = true,
    }
end

return PointLight