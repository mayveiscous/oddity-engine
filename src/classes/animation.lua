local Instance = require("src.core.instance")

local Animation = Instance:RegisterClass("Animation", "Instance")

Animation.Defaults = function()
    return {
        Playing = false,
        Speed = 1,
        Duration = 0,
    }
end

return Animation