local Instance = require("src.core.instance")
local Vector3 = require("src.types.vector3")

local Force = Instance:RegisterClass("Force", "Instance")

Force.Defaults = function()
    return {
        Enabled = true,
        Force = Vector3.new(0, 0, 0),
    } 
end

return Force