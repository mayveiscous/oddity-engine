local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"

local Model = Instance:RegisterClass("Model", "Instance")

Model.Defaults = function()
    return {
        RootPart = nil,
        Position = Vector3.new(0, 0, 0),
        Scale = 1,
    }
end

Model.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent",
    },

    Transform = {
        "Position",
    },

    Model = {
        "RootPart",
        "Scale",
    },
}

return Model