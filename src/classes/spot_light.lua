local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"
local Color3 = require "src.types.color3"

local SpotLight = Instance:RegisterClass("SpotLight", "Instance")

SpotLight.PropertyTypes = {
    Position = "Vector3",
    Direction = "Vector3",
    Color = "Color3",
    InnerAngle = "number",
    OuterAngle = "number",
    Enabled = "boolean",
}

SpotLight.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent",
    },

    SpotLight = {
        "Color",
        "Position",
        "Direction",
        "Enabled",
        "InnerAngle",
        "OuterAngle",
    },
}

SpotLight.Defaults = function()
    return {
        Position = Vector3.new(0, 5, 0),
        Direction = Vector3.new(0, -1, 0),
        Color = Color3.new(1, 1, 1),
        InnerAngle = 12.5,
        OuterAngle = 17.5,
        Enabled = true,
    }
end

return SpotLight