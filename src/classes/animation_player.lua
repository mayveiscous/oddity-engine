local Instance = require("src.core.instance")

local AnimationPlayer = Instance:RegisterClass("AnimationPlayer", "Instance")

AnimationPlayer.PropertyTypes = {
    Animation = "Instance",
    Character = "Instance",
}

AnimationPlayer.Defaults = function()
    return {
        Animation = nil, -- animation instance
        Character = nil, -- character instance
    }
end

return AnimationPlayer