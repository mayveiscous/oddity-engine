local Instance = require("src.core.instance")
local Vector3 = require("src.types.vector3")

local Hinge = Instance:RegisterClass("Hinge", "Instance")

Hinge.Defaults = function()
    return {
        Position = Vector3.new(0, 0, 0),
        Enabled = true,
    }
end

return Hinge