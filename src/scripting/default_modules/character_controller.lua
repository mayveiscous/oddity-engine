local InputService = require("src.classes.inputservice")
local RunService = require("src.classes.runservice")
local Vector3 = require("src.types.vector3")
local CharacterCamera = require("src.scripting.default_modules.character_camera")

local animation_controller = require("src.scripting.default_modules.animation_controller")

local ControllerModule = {}

local subject = nil

local turnSpeed = 6
local wasMoving = false

function ControllerModule.Attach(character)
    subject = character
end

local function cross(a, b)
    return Vector3.new(
        a.Y * b.Z - a.Z * b.Y,
        a.Z * b.X - a.X * b.Z,
        a.X * b.Y - a.Y * b.X
    )
end

RunService.Heartbeat:Connect(function(dt)
    if not subject then return end

    local controller = subject.Controller
    if not controller then return end

    local camForward = CharacterCamera.GetForward()
    local forward = Vector3.new(camForward.X, 0, camForward.Z).Unit
    local right = cross(forward, Vector3.new(0, 1, 0)).Unit

    local moveDir = Vector3.new(0, 0, 0)
    if InputService.IsKeyDown("W") then moveDir = moveDir + forward end
    if InputService.IsKeyDown("S") then moveDir = moveDir - forward end
    if InputService.IsKeyDown("D") then moveDir = moveDir + right end
    if InputService.IsKeyDown("A") then moveDir = moveDir - right end

    local isMoving = moveDir.Magnitude > 0 and controller.Grounded

    if isMoving then
        animation_controller.Play("Walk")
    else
        animation_controller.Stop("Walk")
    end

    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
    end

    local hitbox = subject.RootPart
    if CharacterCamera.IsShiftLocked() then
        local correctedYaw = 90 - CharacterCamera.GetYaw()
        hitbox.Rotation = Vector3.new(hitbox.Rotation.X, correctedYaw, hitbox.Rotation.Z)
    elseif moveDir.Magnitude > 0 then
        local targetYaw = math.deg(math.atan(moveDir.X, moveDir.Z))
        local currentYaw = hitbox.Rotation.Y

        local delta = (targetYaw - currentYaw + 180) % 360 - 180
        local newYaw = currentYaw + delta * math.min(turnSpeed * dt, 1)

        hitbox.Rotation = Vector3.new(hitbox.Rotation.X, newYaw, hitbox.Rotation.Z)
    end

    controller.MoveDirection = moveDir 

    local currentVel = controller.Velocity
    local acceleration = 40 -- units/sec^2, tune to taste

    local desiredVel = Vector3.new(moveDir.X * controller.WalkSpeed, 0, moveDir.Z * controller.WalkSpeed)
    local currentHoriz = Vector3.new(currentVel.X, 0, currentVel.Z)
    local newHoriz = currentHoriz:Lerp(desiredVel, math.min(acceleration * dt, 1))

    controller.Velocity = Vector3.new(newHoriz.X, currentVel.Y, newHoriz.Z)

    if controller.Grounded and InputService.IsKeyDown("Space") then
        controller.Velocity = Vector3.new(
            controller.Velocity.X,
            controller.JumpPower,
            controller.Velocity.Z
        )
        animation_controller.Play("Jump")
    end
end)

return ControllerModule