local Instance = require("src.core.instance")

local AnimationPlayer = Instance:RegisterClass("AnimationPlayer", "Instance")

AnimationPlayer.Defaults = function()
    return {
        Animation = nil, -- animation instance
        Character = nil, -- character instance
    }
end

return AnimationPlayer