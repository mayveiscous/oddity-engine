local Instance = require("src.core.instance")
local Vector3 = require("src.types.vector3")

local Force = Instance:RegisterClass("Force", "Instance")

Force.PropertyTypes = {
    Velocity = "Vector3",
    MaxForce = "Vector3",
}

Force.Defaults = function()
    return {
        Enabled = true,
        Velocity = Vector3.new(0, 0, 0),
        MaxForce = Vector3.new(math.huge, math.huge, math.huge),
    }
end

return Force
