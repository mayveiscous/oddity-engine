local Instance = require("src.core.instance")

local Animation = Instance:RegisterClass("Animation", "Instance")

Animation.Defaults = function()
    return {
        Length = 1.0,
        Tracks = {}, -- { [motorName] = { {time=.., rotation=Vector3}, ... } }
        Looped = true,
    }
end

Animation.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent",
    },
    Animation = {
        "Length",
        "Looped",
        
    },
}

return Animation