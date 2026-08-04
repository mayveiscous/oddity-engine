local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"
local Color3 = require "src.types.color3"

local FrogRig = {}

function FrogRig.Create(parent, position, name)
    position = position or Vector3.new(0, 0, 0)

    local bodyColor = Color3.new(0.32, 0.80, 0.28)
    local bellyColor = Color3.new(0.82, 0.94, 0.72)
    local eyeColor = Color3.new(1, 1, 1)
    local pupilColor = Color3.new(0.05, 0.05, 0.05)

    local character = Instance.new("Character")
    character.Parent = parent
    character.Name = name or "Frog"

    local controller = Instance.new("Controller")
    controller.Parent = character
    character.Controller = controller

    --------------------------------------------------------------------
    -- Sizes
    --------------------------------------------------------------------

    local bodySize = Vector3.new(1.6, 1.0, 1.8)
    local bellySize = Vector3.new(1.2, 0.25, 1.4)

    local headSize = Vector3.new(1.8, 0.9, 1.8)

    local eyeSize = Vector3.new(0.45, 0.45, 0.45)
    local pupilSize = Vector3.new(0.18, 0.18, 0.18)

    local frontLegSize = Vector3.new(0.45, 0.55, 0.45)
    local backLegSize = Vector3.new(0.55, 0.75, 0.55)

    --------------------------------------------------------------------
    -- Hitbox
    --------------------------------------------------------------------

    local totalHeight = backLegSize.Y + bodySize.Y + headSize.Y

    local hitbox = Instance.new("Block")
    hitbox.Parent = character
    hitbox.Name = "Hitbox"
    hitbox.Transparency = 1
    hitbox.Size = Vector3.new(1.8, totalHeight, 2.0)
    hitbox.Position = position + Vector3.new(0, totalHeight / 2, 0)

    character.RootPart = hitbox

    --------------------------------------------------------------------
    -- Body
    --------------------------------------------------------------------

    local body = Instance.new("Block")
    body.Parent = character
    body.Name = "Body"
    body.Size = bodySize
    body.Color = bodyColor

    local bodyMotor = Instance.new("Motor")
    bodyMotor.Parent = hitbox
    bodyMotor.Name = "Body"
    bodyMotor.Part0 = hitbox
    bodyMotor.Part1 = body
    bodyMotor.C0 = Vector3.new(0, backLegSize.Y, 0)
    bodyMotor.C1 = Vector3.zero()

    --------------------------------------------------------------------
    -- Helper
    --------------------------------------------------------------------

    local function attach(parentPart, name, size, color, c0, c1)
        local part = Instance.new("Block")
        part.Parent = character
        part.Name = name
        part.Size = size
        part.Color = color

        local motor = Instance.new("Motor")
        motor.Parent = parentPart
        motor.Name = name
        motor.Part0 = parentPart
        motor.Part1 = part
        motor.C0 = c0
        motor.C1 = c1

        return part, motor
    end

    --------------------------------------------------------------------
    -- Belly
    --------------------------------------------------------------------

    attach(
        body,
        "Belly",
        bellySize,
        bellyColor,
        Vector3.new(0, -0.18, 0),
        Vector3.zero()
    )

    --------------------------------------------------------------------
    -- Head
    --------------------------------------------------------------------

    local head, neck = attach(
        body,
        "Head",
        headSize,
        bodyColor,
        Vector3.new(0, bodySize.Y / 2 - 0.05, 0.35),
        Vector3.new(0, -headSize.Y / 2, 0)
    )

    --------------------------------------------------------------------
    -- Eyes
    --------------------------------------------------------------------

    local leftEye = Instance.new("Block")
    leftEye.Parent = character
    leftEye.Name = "LeftEye"
    leftEye.Size = eyeSize
    leftEye.Color = eyeColor

    local leftEyeMotor = Instance.new("Motor")
    leftEyeMotor.Parent = head
    leftEyeMotor.Part0 = head
    leftEyeMotor.Part1 = leftEye
    leftEyeMotor.C0 = Vector3.new(-0.45, headSize.Y / 2 - 0.08, 0.45)
    leftEyeMotor.C1 = Vector3.zero()

    local rightEye = Instance.new("Block")
    rightEye.Parent = character
    rightEye.Name = "RightEye"
    rightEye.Size = eyeSize
    rightEye.Color = eyeColor

    local rightEyeMotor = Instance.new("Motor")
    rightEyeMotor.Parent = head
    rightEyeMotor.Part0 = head
    rightEyeMotor.Part1 = rightEye
    rightEyeMotor.C0 = Vector3.new(0.45, headSize.Y / 2 - 0.08, 0.45)
    rightEyeMotor.C1 = Vector3.zero()

    --------------------------------------------------------------------
    -- Pupils
    --------------------------------------------------------------------

    local leftPupil = Instance.new("Block")
    leftPupil.Parent = character
    leftPupil.Name = "LeftPupil"
    leftPupil.Size = pupilSize
    leftPupil.Color = pupilColor

    local leftPupilMotor = Instance.new("Motor")
    leftPupilMotor.Parent = leftEye
    leftPupilMotor.Part0 = leftEye
    leftPupilMotor.Part1 = leftPupil
    leftPupilMotor.C0 = Vector3.new(0, 0, eyeSize.Z / 2)
    leftPupilMotor.C1 = Vector3.zero()

    local rightPupil = Instance.new("Block")
    rightPupil.Parent = character
    rightPupil.Name = "RightPupil"
    rightPupil.Size = pupilSize
    rightPupil.Color = pupilColor

    local rightPupilMotor = Instance.new("Motor")
    rightPupilMotor.Parent = rightEye
    rightPupilMotor.Part0 = rightEye
    rightPupilMotor.Part1 = rightPupil
    rightPupilMotor.C0 = Vector3.new(0, 0, eyeSize.Z / 2)
    rightPupilMotor.C1 = Vector3.zero()

    --------------------------------------------------------------------
    -- Legs
    --------------------------------------------------------------------

    local leftFrontLeg, lf = attach(
        body,
        "LeftFrontLeg",
        frontLegSize,
        bodyColor,
        Vector3.new(-0.45, -bodySize.Y / 2 + 0.15, 0.55),
        Vector3.new(0, frontLegSize.Y / 2, 0)
    )

    local rightFrontLeg, rf = attach(
        body,
        "RightFrontLeg",
        frontLegSize,
        bodyColor,
        Vector3.new(0.45, -bodySize.Y / 2 + 0.15, 0.55),
        Vector3.new(0, frontLegSize.Y / 2, 0)
    )

    local leftBackLeg, lb = attach(
        body,
        "LeftBackLeg",
        backLegSize,
        bodyColor,
        Vector3.new(-0.55, -bodySize.Y / 2, -0.55),
        Vector3.new(0, backLegSize.Y / 2, 0)
    )

    local rightBackLeg, rb = attach(
        body,
        "RightBackLeg",
        backLegSize,
        bodyColor,
        Vector3.new(0.55, -bodySize.Y / 2, -0.55),
        Vector3.new(0, backLegSize.Y / 2, 0)
    )

    --------------------------------------------------------------------
    -- Rest Pose
    --------------------------------------------------------------------

    neck.RestRotation = Vector3.new(-5, 0, 0)

    lf.RestRotation = Vector3.new(10, 0, 0)
    rf.RestRotation = Vector3.new(10, 0, 0)

    lb.RestRotation = Vector3.new(-25, 0, -8)
    rb.RestRotation = Vector3.new(-25, 0, 8)

    return character
end

return FrogRig