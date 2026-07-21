local Vector3 = require("src.types.vector3")

local Gravity = {}

local terminalVelocity = -200

function Gravity.ApplyCharacter(character, dt)
    local controller = character.Controller
    if controller.Grounded then
        return
    end

    local newY = controller.Velocity.Y - controller.Gravity * dt
    if newY < terminalVelocity then
        newY = terminalVelocity
    end

    controller.Velocity = Vector3.new(
        controller.Velocity.X,
        newY,
        controller.Velocity.Z
    )
end

return Gravity