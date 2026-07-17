local Instance = require("src.core.instance")
local Vector3 = require("src.types.vector3")

local Character = Instance:RegisterClass("Character", "Instance")

Character.Defaults = function()
    return {
        Controller = nil, -- controller instance
        Position = Vector3.new(0, 0, 0),
    }
end