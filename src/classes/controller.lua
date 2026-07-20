local Instance = require("src.core.instance")

local Vector3 = require("src.types.vector3")

local Controller = Instance:RegisterClass("Controller", "Instance")

Controller.PropertyTypes = {
    WalkSpeed = "number",
    JumpPower = "number",
    Gravity = "number",
    Health = "number",

    MoveDirection = "Vector3",
    Velocity = "Vector3",

    Grounded = "boolean",
}

Controller.Defaults = function()
    return {
        WalkSpeed = 16,
        JumpPower = 50,
        Gravity = 196.2,
        Health = 100,

        MoveDirection = Vector3.zero(),
        Velocity = Vector3.zero(),

        Grounded = false,
    }
end

return Controller