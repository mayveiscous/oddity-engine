local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"
local Color3 = require "src.types.color3"

local Enum = require "src.types.enum"

local DefaultRig = {}

function DefaultRig.Create(parent, position, name)
    local color = Color3.new(0.6, 0.6, 0.5)
    position = position or Vector3.new(0, 0, 0)

    local character = Instance.new("Character")
    character.Parent = parent
    character.Name = name

    local controller = Instance.new("Controller")
    controller.Parent = character
    character.Controller = controller

    local bodySize = Vector3.new(1.4, 1.4, 1.4)
    local armSize = Vector3.new(0.4, 1.4, 0.4)
    local legSize = Vector3.new(0.4, 0.75, 0.4)

    local bodyY = legSize.Y + (bodySize.Y / 2)

    local body = Instance.new("Block")
    body.Parent = character
    body.Size = bodySize
    body.Position = Vector3.new(position.X, position.Y + bodyY, position.Z)
    body.Color = color
    body.Name = "Body"

    local face = Instance.new("Texture")
    face.Name = "face"
    face.Face = Enum.Faces.Back
    face.Image = "Default"
    face.Parent = body

    local hitboxHeight = legSize.Y + bodySize.Y
    local hitbox = Instance.new("Block")
    hitbox.Parent = character
    hitbox.Name = "Hitbox"
    hitbox.Transparency = 1
    hitbox.Size = Vector3.new(1.2, hitboxHeight, 1.2)
    hitbox.Position = Vector3.new(position.X, position.Y + hitboxHeight / 2, position.Z)

    character.RootPart = hitbox

    local bodyMotor = Instance.new("Motor")
    bodyMotor.Parent = hitbox
    bodyMotor.Part0 = hitbox
    bodyMotor.Part1 = body
    bodyMotor.C0 = Vector3.new(0, legSize.Y / 2, 0)
    bodyMotor.C1 = Vector3.zero()
    bodyMotor.Name = "BodyMotor"

    local function attachLimb(name, size, c0, c1, limbColor)
        local limb = Instance.new("Block")
        limb.Parent = character
        limb.Size = size
        limb.Color = limbColor
        limb.Name = name

        local motor = Instance.new("Motor")
        motor.Parent = body
        motor.Part0 = body
        motor.Part1 = limb
        motor.C0 = c0
        motor.C1 = c1
        motor.Name = name
        return limb, motor
    end

    local leftArm, leftArmMotor = attachLimb(
        "LeftArm", armSize,
        Vector3.new(-(bodySize.X / 2) + 0.15, bodySize.Y / 2 - 0.5, 0),
        Vector3.new(0, armSize.Y / 2, 0),
        color
    )
    leftArmMotor.RestRotation = Vector3.new(0, 0, -45)

    local rightArm, rightArmMotor = attachLimb(
        "RightArm", armSize,
        Vector3.new((bodySize.X / 2) - 0.15, bodySize.Y / 2 - 0.5, 0),
        Vector3.new(0, armSize.Y / 2, 0),
        color
    )
    rightArmMotor.RestRotation = Vector3.new(0, 0, 45)

    local leftLeg, leftLegMotor = attachLimb(
        "LeftLeg", legSize,
        Vector3.new(-0.35, -(bodySize.Y / 2), 0),
        Vector3.new(0, legSize.Y / 2, 0),
        Color3.new(0.2, 0.3, 0.8)
    )
    local rightLeg, rightLegMotor = attachLimb(
        "RightLeg", legSize,
        Vector3.new(0.35, -(bodySize.Y / 2), 0),
        Vector3.new(0, legSize.Y / 2, 0),
        Color3.new(0.2, 0.3, 0.8)
    )

    return character
end

return DefaultRig