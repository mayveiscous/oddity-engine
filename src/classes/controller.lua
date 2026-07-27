local Instance = require "src.core.instance"

local Vector3 = require "src.types.vector3"

local Controller = Instance:RegisterClass("Controller", "Instance")

Controller.PropertyTypes = {
    WalkSpeed = "number",
    JumpPower = "number",
    Health = "number",
    MoveDirection = "Vector3",
}

Controller.Properties = {
    Data = { "Name", "ClassName", "Parent" },
    Controller = { "Health", "WalkSpeed", "JumpPower", "MoveDirection" },
}

Controller.Defaults = function()
    return {
        WalkSpeed = 16,
        JumpPower = 40,
        Health = 100,
        MoveDirection = Vector3.zero(),
    }
end

return Controller