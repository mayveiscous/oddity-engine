local Instance = require("src.core.instance")

local Vector3 = require("src.types.vector3")

local Motor = Instance:RegisterClass("Motor", "Instance")

Motor.PropertyTypes = {
    Part0 = "Instance",
    Part1 = "Instance",
    C0 = "Vector3",
    C1 = "Vector3",
    RestRotation = "Vector3",
    CurrentRotation = "Vector3",
}

Motor.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent",
    },

    Motor = {
        "Part0",
        "Part1",
        "C0",
        "C1",
        "RestRotation",
        "CurrentRotation",
    },
}

Motor.Defaults = function()
    return {
        Part0 = nil,
        Part1 = nil,
        C0 = Vector3.Zero,
        C1 = Vector3.Zero,
        RestRotation = Vector3.Zero,
        CurrentRotation = Vector3.Zero,
    }
end

return Motor