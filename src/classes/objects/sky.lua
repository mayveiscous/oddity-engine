local Instance = require "src.core.instance"

local Sky = Instance:RegisterClass("Sky", "Instance", {
    Properties = {
        Texture = {
            type = "string",
            default = "",
            category = "Appearance",
        },
    },
})

return Sky