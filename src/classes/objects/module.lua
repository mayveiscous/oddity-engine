local Instance = require "src.core.instance"

local Module = Instance:RegisterClass("Module", "Instance", {
    Properties = {
        Source = {
            type = "string",
            default = "",
            category = "Script",
        },
    },
})

return Module