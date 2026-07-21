local AABB = require("src.physics.aabb")
local Vector3 = require("src.types.vector3")
local Slope = require("src.physics.slope")

local CharacterPhysics = {}

local maxStepHeight = 0.5
local groundProbeDistance = 0.05

function CharacterPhysics.getAllColliders(workspace)
    local colliders = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.CanCollide then
            table.insert(colliders, obj)
        end
    end
    return colliders
end

function CharacterPhysics.collidersForCharacter(allColliders, character)
    local filtered = {}
    for _, obj in ipairs(allColliders) do
        if not obj:IsDescendantOf(character) then
            table.insert(filtered, obj)
        end
    end
    return filtered
end

function CharacterPhysics.overlapsWedge(characterBlock, wedge)
    local box = AABB.fromBlock(characterBlock)

    local wedgeBox = AABB.fromBlock(wedge)

    if box.maxX <= wedgeBox.minX
        or box.minX >= wedgeBox.maxX
        or box.maxZ <= wedgeBox.minZ
        or box.minZ >= wedgeBox.maxZ then
        return false
    end

    local slopeY = Slope.getHeightAt(
        wedge,
        characterBlock.Position.X,
        characterBlock.Position.Z
    )

    if not slopeY then
        return false
    end

    if box.minY >= slopeY then
        return false
    end

    return true
end

function CharacterPhysics.projectOnSlope(velocity, slopeNormal)
    local dot = velocity.X * slopeNormal.X
              + velocity.Y * slopeNormal.Y
              + velocity.Z * slopeNormal.Z
    return Vector3.new(
        velocity.X - dot * slopeNormal.X,
        velocity.Y - dot * slopeNormal.Y,
        velocity.Z - dot * slopeNormal.Z
    )
end

function CharacterPhysics.checkGrounded(characterBlock, colliders)
    local pos = characterBlock.Position

    characterBlock.Position = Vector3.new(pos.X, pos.Y - groundProbeDistance, pos.Z)
    local myBox = AABB.fromBlock(characterBlock)
    characterBlock.Position = pos

    for _, collider in ipairs(colliders) do
        if collider ~= characterBlock then
            if collider:IsA("Block") and collider.Shape == "Wedge" then
                goto continue
            end
            if AABB.overlaps(myBox, AABB.fromBlock(collider)) then
                return true
            end
        end
        ::continue::
    end

    return false
end

function CharacterPhysics.querySlopeAtCharacter(root, colliders)
    local pos = root.Position
    local halfX = root.Size.X / 2
    local halfZ = root.Size.Z / 2

    local bestSlope = nil

    for _, collider in ipairs(colliders) do
        if collider:IsA("Block") and collider.Shape == "Wedge" and collider.CanCollide then
            local slopeY = Slope.getHeightAtFootprint(
                collider,
                pos.X, pos.Z,
                halfX, halfZ
            )

            if slopeY then
                local feetY = pos.Y - (root.Size.Y / 2)
                local gap = slopeY - feetY

                if gap >= -0.3 and gap <= 0.5 then
                    if not bestSlope or gap > (bestSlope.gap or -math.huge) then
                        bestSlope = {
                            wedge = collider,
                            height = slopeY,
                            normal = Slope.getNormal(collider),
                            angle = Slope.getSlopeAngle(collider),
                            gap = gap,
                        }
                    end
                end
            end
        end
    end

    return bestSlope
end

function CharacterPhysics.tryStepUp(characterBlock, axis, delta, colliders)
    local original = characterBlock.Position

    characterBlock.Position = Vector3.new(
        original.X,
        original.Y + maxStepHeight,
        original.Z
    )

    local liftedBox = AABB.fromBlock(characterBlock)
    for _, collider in ipairs(colliders) do
        if collider ~= characterBlock and AABB.overlaps(liftedBox, AABB.fromBlock(collider)) then
            characterBlock.Position = original
            return false
        end
    end

    local pos = characterBlock.Position
    if axis == "X" then
        characterBlock.Position = Vector3.new(pos.X + delta, pos.Y, pos.Z)
    elseif axis == "Z" then
        characterBlock.Position = Vector3.new(pos.X, pos.Y, pos.Z + delta)
    end

    local movedBox = AABB.fromBlock(characterBlock)
    for _, collider in ipairs(colliders) do
        if collider ~= characterBlock then
            if AABB.overlaps(movedBox, AABB.fromBlock(collider)) then
                characterBlock.Position = original
                return false
            end
        end
    end

    CharacterPhysics.resolveAxis(characterBlock, "Y", -(maxStepHeight + 0.1), colliders)

    return true
end

function CharacterPhysics.resolveAxis(characterBlock, axis, delta, colliders)
    local pos = characterBlock.Position

    if axis == "X" then
        characterBlock.Position = Vector3.new(pos.X + delta, pos.Y, pos.Z)
    elseif axis == "Y" then
        characterBlock.Position = Vector3.new(pos.X, pos.Y + delta, pos.Z)
    elseif axis == "Z" then
        characterBlock.Position = Vector3.new(pos.X, pos.Y, pos.Z + delta)
    end

    local myBox = AABB.fromBlock(characterBlock)
    local bestCorrection = nil

    for _, collider in ipairs(colliders) do
        if collider ~= characterBlock then

            local isWedge = collider:IsA("Block") and collider.Shape == "Wedge"
            local otherBox = isWedge and nil or AABB.fromBlock(collider)
            local hit

            if isWedge then
                hit = CharacterPhysics.overlapsWedge(characterBlock, collider)
            else
                hit = AABB.overlaps(myBox, otherBox)
            end

            if hit then
                local correction

                if isWedge and axis == "Y" then
                    local slopeY = Slope.getHeightAt(
                        collider,
                        characterBlock.Position.X,
                        characterBlock.Position.Z
                    )
                    if slopeY then
                        correction = slopeY - myBox.minY
                    end
                elseif axis == "X" then
                    correction = (delta > 0)
                        and (otherBox.minX - myBox.maxX)
                        or (otherBox.maxX - myBox.minX)

                elseif axis == "Y" then
                    correction = (delta > 0)
                        and (otherBox.minY - myBox.maxY)
                        or (otherBox.maxY - myBox.minY)

                elseif axis == "Z" then
                    correction = (delta > 0)
                        and (otherBox.minZ - myBox.maxZ)
                        or (otherBox.maxZ - myBox.minZ)
                end

                if correction and (not bestCorrection
                    or math.abs(correction) < math.abs(bestCorrection)) then
                    bestCorrection = correction
                end
            end
        end
    end

    if bestCorrection then
        local newPos = characterBlock.Position

        if axis == "X" then
            characterBlock.Position = Vector3.new(
                newPos.X + bestCorrection,
                newPos.Y,
                newPos.Z
            )

        elseif axis == "Y" then
            characterBlock.Position = Vector3.new(
                newPos.X,
                newPos.Y + bestCorrection,
                newPos.Z
            )

        elseif axis == "Z" then
            characterBlock.Position = Vector3.new(
                newPos.X,
                newPos.Y,
                newPos.Z + bestCorrection
            )
        end

        return true
    end

    return false
end

return CharacterPhysics
