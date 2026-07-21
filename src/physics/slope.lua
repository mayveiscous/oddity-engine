local Vector3 = require("src.types.vector3")

local Slope = {}

Slope.WALKABLE_ANGLE = 45
Slope.SLIDE_ANGLE = 60
Slope.WALL_ANGLE = 75

local yAxis = Vector3.new(0, 1, 0)

function Slope.getNormal(wedge)
    local acrossVec = Vector3.new(1, 0, 0)
    local slopeVec = Vector3.new(0, wedge.Size.Y, -wedge.Size.Z)

    local rawNormal = Vector3.new(
        acrossVec.Y * slopeVec.Z - acrossVec.Z * slopeVec.Y,
        acrossVec.Z * slopeVec.X - acrossVec.X * slopeVec.Z,
        acrossVec.X * slopeVec.Y - acrossVec.Y * slopeVec.X
    )

    local yawRad = math.rad(wedge.Rotation.Y)
    local cosY = math.cos(yawRad)
    local sinY = math.sin(yawRad)

    return Vector3.new(
        rawNormal.X * cosY - rawNormal.Z * sinY,
        rawNormal.Y,
        rawNormal.X * sinY + rawNormal.Z * cosY
    ).Unit
end

function Slope.getSlopeAngle(wedge)
    local normal = Slope.getNormal(wedge)
    local dot = normal.X * yAxis.X + normal.Y * yAxis.Y + normal.Z * yAxis.Z
    if dot < -1 then dot = -1 end
    if dot > 1 then dot = 1 end
    return math.deg(math.acos(dot))
end

function Slope.getHeightAt(wedge, worldX, worldZ)
    local relX = worldX - wedge.Position.X
    local relZ = worldZ - wedge.Position.Z

    local yawRad = -math.rad(wedge.Rotation.Y)
    local localX = relX * math.cos(yawRad) - relZ * math.sin(yawRad)
    local localZ = relX * math.sin(yawRad) + relZ * math.cos(yawRad)

    local halfX = wedge.Size.X / 2
    local halfZ = wedge.Size.Z / 2

    if localX < -halfX or localX > halfX or localZ < -halfZ or localZ > halfZ then
        return nil
    end

    local t = (halfZ - localZ) / (2 * halfZ)
    local localHeight = t * wedge.Size.Y

    return wedge.Position.Y - (wedge.Size.Y / 2) + localHeight
end

function Slope.getHeightAtFootprint(wedge, centerX, centerZ, halfExtentsX, halfExtentsZ)
    local bestY = nil

    local offsets = {
        { 0, 0 },
        { halfExtentsX, 0 },
        { -halfExtentsX, 0 },
        { 0, halfExtentsZ },
        { 0, -halfExtentsZ },
    }

    for _, off in ipairs(offsets) do
        local h = Slope.getHeightAt(wedge, centerX + off[1], centerZ + off[2])
        if h and (not bestY or h > bestY) then
            bestY = h
        end
    end

    return bestY
end

function Slope.getDownhillDirection(wedge)
    local normal = Slope.getNormal(wedge)
    local downHill = Vector3.new(normal.X, 0, normal.Z)
    local mag = math.sqrt(downHill.X * downHill.X + downHill.Z * downHill.Z)
    if mag < 0.001 then
        return Vector3.new(0, 0, 0)
    end
    return Vector3.new(downHill.X / mag, 0, downHill.Z / mag)
end

return Slope
