local Instance = require("src.core.instance")

local Player = Instance:RegisterClass("Player", "Instance")

Player.PropertyTypes = {
    Character = "Instance",
    UserId = "number",
}

Player.Defaults = function()
    return {
        Character = nil,
        UserId = 0,
    }
end

return Player