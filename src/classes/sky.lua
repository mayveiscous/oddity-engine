local Instance = require("src.core.instance")

local Vector3 = require("src.types.vector3")
local Color3 = require("src.types.color3")

local Sky = Instance:RegisterClass("Sky", "Instance")

Sky.PropertyTypes = {
    Texture = "string",
}

Sky.Defaults = function()
    return {
        Texture = nil,
    }
end

return Sky