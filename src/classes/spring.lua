local Instance = require("src.core.instance")
local Vector3 = require("src.types.vector3")

local Spring = Instance:RegisterClass("Spring", "Instance")

Spring.Defaults = function()
    return {
        Position = Vector3.new(0, 0, 0),
        Force = vector3.new(0, 0, 0),
    }
end

return Spring