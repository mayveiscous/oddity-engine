local Vector3 = require("src.types.vector3")
local Game = require("src.game")

local CharacterPhysics = require("src.physics.character_physics")
local Gravity = require("src.physics.gravity")
local Slope = require("src.physics.slope")

local PhysicsRuntime = {}

local function resolveCharacter(character, colliders, dt)
    local controller = character.Controller
    local root = character.RootPart

    Gravity.ApplyCharacter(character, dt)

    local velocity = controller.Velocity

    local slopeInfo = CharacterPhysics.querySlopeAtCharacter(root, colliders)

    local grounded = false
    local groundedOnSlope = false

    if slopeInfo and slopeInfo.angle <= Slope.WALL_ANGLE then
        local feetY = root.Position.Y - (root.Size.Y / 2)
        local gap = slopeInfo.height - feetY

        if velocity.Y <= 0 and gap >= -0.1 and gap <= 0.3 then
            if slopeInfo.angle <= Slope.WALKABLE_ANGLE then
                groundedOnSlope = true
                grounded = true
            elseif slopeInfo.angle <= Slope.SLIDE_ANGLE then
                groundedOnSlope = true
                grounded = true
            end
        end
    end

    if not grounded then
        if velocity.Y <= 0 then
            grounded = CharacterPhysics.checkGrounded(root, colliders)
        end
    end

    if grounded then
        velocity.Y = 0

        if groundedOnSlope then
            local moveVel = Vector3.new(velocity.X, 0, velocity.Z)
            local projected = CharacterPhysics.projectOnSlope(moveVel, slopeInfo.normal)

            CharacterPhysics.resolveAxis(root, "Y", projected.Y * dt, colliders)

            local originalPos = root.Position
            local hitX = CharacterPhysics.resolveAxis(root, "X", projected.X * dt, colliders)
            if hitX then
                root.Position = originalPos
                CharacterPhysics.tryStepUp(root, "X", projected.X * dt, colliders)
            end

            local posAfterX = root.Position
            local hitZ = CharacterPhysics.resolveAxis(root, "Z", projected.Z * dt, colliders)
            if hitZ then
                root.Position = posAfterX
                CharacterPhysics.tryStepUp(root, "Z", projected.Z * dt, colliders)
            end

            local snapSlope = CharacterPhysics.querySlopeAtCharacter(root, colliders)
            if snapSlope and snapSlope.angle <= Slope.SLIDE_ANGLE then
                local newFeetY = root.Position.Y - (root.Size.Y / 2)
                local snapGap = snapSlope.height - newFeetY
                if snapGap >= -0.05 and snapGap <= 0.15 then
                    root.Position = Vector3.new(
                        root.Position.X,
                        snapSlope.height + (root.Size.Y / 2),
                        root.Position.Z
                    )
                end
            end
        else
            local originalPos = root.Position
            local hitX = CharacterPhysics.resolveAxis(root, "X", velocity.X * dt, colliders)
            if hitX then
                root.Position = originalPos
                CharacterPhysics.tryStepUp(root, "X", velocity.X * dt, colliders)
            end

            local posAfterX = root.Position
            local hitZ = CharacterPhysics.resolveAxis(root, "Z", velocity.Z * dt, colliders)
            if hitZ then
                root.Position = posAfterX
                CharacterPhysics.tryStepUp(root, "Z", velocity.Z * dt, colliders)
            end
        end

        if groundedOnSlope and slopeInfo.angle > Slope.WALKABLE_ANGLE then
            local slideDir = Slope.getDownhillDirection(slopeInfo.wedge)
            local slideForce = controller.Gravity * math.sin(math.rad(slopeInfo.angle))
            controller.Velocity = Vector3.new(
                velocity.X + slideDir.X * slideForce * dt,
                0,
                velocity.Z + slideDir.Z * slideForce * dt
            )
        end
    else
        CharacterPhysics.resolveAxis(root, "Y", velocity.Y * dt, colliders)

        local originalPos = root.Position
        local hitX = CharacterPhysics.resolveAxis(root, "X", velocity.X * dt, colliders)
        if hitX then
            root.Position = originalPos
            CharacterPhysics.tryStepUp(root, "X", velocity.X * dt, colliders)
        end

        local posAfterX = root.Position
        local hitZ = CharacterPhysics.resolveAxis(root, "Z", velocity.Z * dt, colliders)
        if hitZ then
            root.Position = posAfterX
            CharacterPhysics.tryStepUp(root, "Z", velocity.Z * dt, colliders)
        end
    end

    controller.Grounded = grounded
end

local function applyForces(forces, dt)
    for _, force in ipairs(forces) do
        local parent = force.Parent

        if parent and parent.Position then
            local vel = force.Velocity
            local max = force.MaxForce
            local pos = parent.Position

            parent.Position = Vector3.new(
                pos.X + ((max.X ~= 0) and vel.X or 0) * dt,
                pos.Y + ((max.Y ~= 0) and vel.Y or 0) * dt,
                pos.Z + ((max.Z ~= 0) and vel.Z or 0) * dt
            )
        end
    end
end

function PhysicsRuntime.Update(dt, characters, forces)
    local allColliders = CharacterPhysics.getAllColliders(Game.Workspace)

    for _, character in ipairs(characters) do
        local colliders = CharacterPhysics.collidersForCharacter(
            allColliders,
            character
        )

        resolveCharacter(character, colliders, dt)
    end

    applyForces(forces, dt)
end

return PhysicsRuntime
