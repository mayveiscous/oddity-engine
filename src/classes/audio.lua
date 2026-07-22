local Instance = require("src.core.instance")

local Audio = Instance:RegisterClass("Audio", "Instance")

Audio.Defaults = function()
    return {
        Volume = 1,
    }
end

Audio.Properties = {
    Data = {
        "Name",
        "Volume",
    }
}

return Audio