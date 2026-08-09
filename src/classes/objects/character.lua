local Instance = require "src.core.instance"

local Character = Instance:RegisterClass("Character", "Instance", {
    Properties = {
        Controller = {
            type = "Instance",
            default = nil,
            category = "Character",
        },

        RootPart = {
            type = "Instance",
            default = nil,
            category = "Character",
        },
    },
})

return Character