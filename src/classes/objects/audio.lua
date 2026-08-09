local Instance = require "src.core.instance"

local Audio = Instance:RegisterClass("Audio", "Instance", {
    Properties = {
        Volume = {
            type = "number",
            default = 1,
            category = "Data",
        },
    },
})

return Audio