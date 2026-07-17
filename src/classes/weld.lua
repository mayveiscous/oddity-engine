local Instance = require("src.core.instance")
local Vector3 = require("src.types.vector3")

local Weld = Instance:RegisterClass("Weld", "Instance")

Weld.Defaults = function()
    return {
        Position = Vector3.new(0, 0, 0),
        Enabled = true,
    }
end

return Weld