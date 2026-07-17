local Instance = require("src.core.instance")
local Vector3 = require("src.types.vector3")

local Block = Instance:RegisterClass("Block", "Instance")

Block.Defaults = function()
    return {
        Position = Vector3.new(0, 0, 0),
        Size = Vector3.new(1, 1, 1),
        Anchored = false,
        CanCollide = true,
    }
end

return Block