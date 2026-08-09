local Instance = require "src.core.instance"

local Spawn = Instance:RegisterClass("Spawn", "Block", {
    Properties = {
        Enabled = {
            type = "boolean",
            default = true,
            category = "Spawn",
        },

        ProtectionDuration = {
            type = "number",
            default = 3,
            category = "Spawn",
        },
    },
})

return Spawn