local Instance = require "src.core.instance"

local SoundStorage = Instance:RegisterClass("SoundStorage", "Service", {
    Properties = {
        ShowInExplorer = {
            type = "boolean",
            default = true,
            category = "Hidden"
        },
    },
})

return SoundStorage