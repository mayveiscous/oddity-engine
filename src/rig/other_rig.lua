local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"
local Color3 = require "src.types.color3"

local DefaultRigV2 = {}

function DefaultRigV2.Create(parent, position, name)
    position = position or Vector3.zero()

    local skin = Color3.new(0.90, 0.82, 0.68)
    local shirt = Color3.new(0.22, 0.45, 0.85)
    local pants = Color3.new(0.18, 0.18, 0.22)

    local character = Instance.new("Character")
    character.Parent = parent
    character.Name = name

    local controller = Instance.new("Controller")
    controller.Parent = character
    character.Controller = controller

    controller.JumpPower = 150

    -- Body dimensions
    local torsoSize = Vector3.new(1.2, 1.6, 0.7)
    local headSize = Vector3.new(0.8, 0.8, 0.8)

    local armSize = Vector3.new(0.35, 1.35, 0.35)
    local legSize = Vector3.new(0.45, 1.1, 0.45)

    local legHeight = legSize.Y
    local torsoCenter = legHeight + torsoSize.Y / 2

    ----------------------------------------------------
    -- Hitbox
    ----------------------------------------------------

    local totalHeight = legSize.Y + torsoSize.Y + headSize.Y

    local hitbox = Instance.new("Block")
    hitbox.Parent = character
    hitbox.Name = "Hitbox"
    hitbox.Transparency = 1
    hitbox.Size = Vector3.new(1.1, totalHeight, 1.1)
    hitbox.Position = position + Vector3.new(0, totalHeight / 2, 0)

    character.RootPart = hitbox

    ----------------------------------------------------
    -- Torso
    ----------------------------------------------------

    local torso = Instance.new("Block")
    torso.Parent = character
    torso.Name = "Torso"
    torso.Size = torsoSize
    torso.Position = position + Vector3.new(0, torsoCenter, 0)
    torso.Color = shirt

    local rootMotor = Instance.new("Motor")
    rootMotor.Parent = hitbox
    rootMotor.Name = "Root"
    rootMotor.Part0 = hitbox
    rootMotor.Part1 = torso
    rootMotor.C0 = Vector3.new(0, legSize.Y, 0)
    rootMotor.C1 = Vector3.zero()

    ----------------------------------------------------
    -- Helper
    ----------------------------------------------------

    local function attach(name, size, color, c0, c1)
        local part = Instance.new("Block")
        part.Parent = character
        part.Name = name
        part.Size = size
        part.Color = color

        local motor = Instance.new("Motor")
        motor.Parent = torso
        motor.Name = name
        motor.Part0 = torso
        motor.Part1 = part
        motor.C0 = c0
        motor.C1 = c1

        return part, motor
    end

    ----------------------------------------------------
    -- Head
    ----------------------------------------------------

    local head, neck = attach(
        "Head",
        headSize,
        skin,
        Vector3.new(0, torsoSize.Y / 2, 0),
        Vector3.new(0, -headSize.Y / 2, 0)
    )

    ----------------------------------------------------
    -- Arms
    ----------------------------------------------------

    local leftArm, leftShoulder = attach(
        "LeftArm",
        armSize,
        shirt,
        Vector3.new(-(torsoSize.X / 2), torsoSize.Y / 2 - 0.2, 0),
        Vector3.new(0, armSize.Y / 2, 0)
    )

    leftShoulder.RestRotation = Vector3.new(0, 0, -10)

    local rightArm, rightShoulder = attach(
        "RightArm",
        armSize,
        shirt,
        Vector3.new(torsoSize.X / 2, torsoSize.Y / 2 - 0.2, 0),
        Vector3.new(0, armSize.Y / 2, 0)
    )

    rightShoulder.RestRotation = Vector3.new(0, 0, 10)

    ----------------------------------------------------
    -- Legs
    ----------------------------------------------------

    local leftLeg, leftHip = attach(
        "LeftLeg",
        legSize,
        pants,
        Vector3.new(-0.28, -torsoSize.Y / 2, 0),
        Vector3.new(0, legSize.Y / 2, 0)
    )

    local rightLeg, rightHip = attach(
        "RightLeg",
        legSize,
        pants,
        Vector3.new(0.28, -torsoSize.Y / 2, 0),
        Vector3.new(0, legSize.Y / 2, 0)
    )

    return character
end

return DefaultRigV2