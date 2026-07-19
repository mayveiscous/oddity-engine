local Instance = require("scr.core.instance")

local Motor = Instance:RegisterClass("Motor", "Instance")

Motor.PropertyTypes = {
    Part0 = "Instance",
    Part1 = "Instance",
    C0 = "Vector3",
    C1 = "Vector3",
    CurrentRotation = "Vector3",
}

Motor.Defaults = function()
    return {
        Part0 = nil,
        Part1 = nil,
        C0 = Vector3.Zero,
        C1 = Vector3.Zero,
        CurrentRotation = Vector3.Zero,
    }
end

return Motor