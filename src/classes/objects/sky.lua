local Instance = require "src.core.instance"

local Sky = Instance:RegisterClass("Sky", "Instance", {
    Properties = {
        Texture = {
            type = "string",
            default = nil,
            category = "Appearance",
        },
    },
})

return Sky