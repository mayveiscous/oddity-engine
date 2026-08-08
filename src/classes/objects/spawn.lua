local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"

local Spawn = Instance:RegisterClass("Spawn", "Block")

Spawn.Defaults = function()
    return {
        Enabled = true,
        ProtectionDuration = 3,
    }
end

Spawn.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent",
    },

    Spawn = {
        "Enabled",
        "ProtectionDuration",
    }
}

return Spawn