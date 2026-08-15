local Vector3 = require "src.types.vector3"
local Plane = require "src.physics.colliders.plane"

local ConvexHull = {}
ConvexHull.__index = ConvexHull

local function buildMeta(planes, vertices)
    local self = {}
    self.normalized = {}

    for i, plane in ipairs(planes) do
        local norm = plane:Normalize()
        self.normalized[i] = norm
    end

    self.worldVertices = vertices

    self.Type = "ConvexHull"

    return self
end

function ConvexHull.new(planes, vertices)
    return setmetatable(buildMeta(planes, vertices), ConvexHull)
end

function ConvexHull:IntersectSphere(sphere)
    local bestDistance = -math.huge
    local bestPlane = nil

    for _, plane in ipairs(self.normalized) do
        local result = plane:IntersectSphere(sphere)

        if not result.Intersects then
            return {
                Intersects = false,
                Distance = 0,
                Normal = Vector3.zero()
            }
        end

        if result.Distance > bestDistance then
            bestDistance = result.Distance
            bestPlane = plane
        end
    end

    return {
        Intersects = true,
        Distance = bestDistance,
        Normal = bestPlane.m_normal
    }
end

local axisNames = { "X", "Y", "Z" }
local axisVectors = {
    X = Vector3.new(1, 0, 0),
    Y = Vector3.new(0, 1, 0),
    Z = Vector3.new(0, 0, 1),
}

local function axisCandidate(worldVertices, axisName, box)
    local hullMin, hullMax = math.huge, -math.huge

    for _, v in ipairs(worldVertices) do
        local proj = v[axisName]
        if proj < hullMin then hullMin = proj end
        if proj > hullMax then hullMax = proj end
    end

    local boxMin, boxMax = box.min[axisName], box.max[axisName]

    if boxMax <= hullMin or boxMin >= hullMax then
        return nil
    end

    local overlapPos = hullMax - boxMin
    local overlapNeg = boxMax - hullMin

    if overlapPos < overlapNeg then
        return { distance = -overlapPos, normal = axisVectors[axisName] }
    else
        return { distance = -overlapNeg, normal = -axisVectors[axisName] }
    end
end

function ConvexHull:IntersectAABB(box)
    local center = (box.min + box.max) / 2
    local half = box.half

    local bestDistance = -math.huge
    local bestNormal = nil

    for _, plane in ipairs(self.normalized) do
        local n = plane.m_normal
        local r = half.X * math.abs(n.X) + half.Y * math.abs(n.Y) + half.Z * math.abs(n.Z)
        local centerDist = n:Dot(center) + plane.m_distance
        local distanceFromSurface = centerDist - r

        if distanceFromSurface >= 0 then
            return {
                Intersects = false,
                Distance = 0,
                Normal = Vector3.zero()
            }
        end

        if distanceFromSurface > bestDistance then
            bestDistance = distanceFromSurface
            bestNormal = n
        end
    end

    if self.worldVertices then
        for _, axisName in ipairs(axisNames) do
            local candidate = axisCandidate(self.worldVertices, axisName, box)

            if not candidate then
                return {
                    Intersects = false,
                    Distance = 0,
                    Normal = Vector3.zero()
                }
            end

            if candidate.distance > bestDistance then
                bestDistance = candidate.distance
                bestNormal = candidate.normal
            end
        end
    end

    return {
        Intersects = true,
        Distance = bestDistance,
        Normal = bestNormal
    }
end

-- Local-space wedge geometry, matching src/render/shapes.lua's Shapes.Wedge
-- vertex data exactly (same A-F corner naming).
local wedgeCorners = {
    A = Vector3.new(-0.5, -0.5, -0.5), -- bottom-back-left
    B = Vector3.new( 0.5, -0.5, -0.5), -- bottom-back-right
    C = Vector3.new(-0.5, -0.5,  0.5), -- bottom-front-left
    D = Vector3.new( 0.5, -0.5,  0.5), -- bottom-front-right
    E = Vector3.new(-0.5,  0.5, -0.5), -- top-back-left
    F = Vector3.new( 0.5,  0.5, -0.5), -- top-back-right
}

local wedgeLocalPlanes = {
    { normal = Vector3.new(0, -1, 0), point = wedgeCorners.A },        -- bottom
    { normal = Vector3.new(0, 0, -1), point = wedgeCorners.A },        -- back
    { normal = Vector3.new(0, 0.7071, 0.7071), point = wedgeCorners.C }, -- slope
    { normal = Vector3.new(-1, 0, 0), point = wedgeCorners.A },        -- left
    { normal = Vector3.new(1, 0, 0), point = wedgeCorners.B },         -- right
}

local function rotateY(v, deg)
    local rad = math.rad(deg)
    local c, s = math.cos(rad), math.sin(rad)
    return Vector3.new(v.X * c + v.Z * s, v.Y, -v.X * s + v.Z * c)
end

local function rotateX(v, deg)
    local rad = math.rad(deg)
    local c, s = math.cos(rad), math.sin(rad)
    return Vector3.new(v.X, v.Y * c - v.Z * s, v.Y * s + v.Z * c)
end

local function rotateZ(v, deg)
    local rad = math.rad(deg)
    local c, s = math.cos(rad), math.sin(rad)
    return Vector3.new(v.X * c - v.Y * s, v.X * s + v.Y * c, v.Z)
end

-- Local POINT -> world space, matching render_module.cpp's model matrix
-- order exactly: scale, then rotate Z, then rotate X, then rotate Y, then
-- translate.
local function transformPoint(localPoint, position, size, rotation)
    local scaled = Vector3.new(localPoint.X * size.X, localPoint.Y * size.Y, localPoint.Z * size.Z)
    local rz = rotateZ(scaled, rotation.Z)
    local rx = rotateX(rz, rotation.X)
    local ry = rotateY(rx, rotation.Y)
    return ry + position
end

-- Local NORMAL -> world space using the inverse-transpose of the model's
-- linear part, so non-uniform Size doesn't skew the normal's direction.
local function transformNormal(localNormal, size, rotation)
    local ry = rotateY(localNormal, rotation.Y)
    local rx = rotateX(ry, rotation.X)
    local rz = rotateZ(rx, rotation.Z)
    local unscaled = Vector3.new(rz.X / size.X, rz.Y / size.Y, rz.Z / size.Z)
    return unscaled.Unit
end

local function inverseTransformPoint(worldPoint, position, size, rotation)
    local localPos = worldPoint - position
    local afterInvY = rotateY(localPos, -rotation.Y)
    local afterInvX = rotateX(afterInvY, -rotation.X)
    local afterInvZ = rotateZ(afterInvX, -rotation.Z)
    return Vector3.new(afterInvZ.X / size.X, afterInvZ.Y / size.Y, afterInvZ.Z / size.Z)
end

function ConvexHull.fromWedge(block, positionOverride)
    local position = positionOverride or block.Position
    local size = block.Size
    local rotation = block.Rotation

    local planes = {}
    for i, def in ipairs(wedgeLocalPlanes) do
        local worldNormal = transformNormal(def.normal, size, rotation)
        local worldPoint = transformPoint(def.point, position, size, rotation)
        local distance = -worldNormal:Dot(worldPoint)

        planes[i] = Plane.new(worldNormal, distance)
    end

    local worldVertices = {}
    for name, corner in pairs(wedgeCorners) do
        worldVertices[#worldVertices + 1] = transformPoint(corner, position, size, rotation)
    end

    return ConvexHull.new(planes, worldVertices)
end

-- Straight-down ray probe against just the wedge's slope face - a much
-- narrower, more reliable question ("what's directly below me") than the
-- penetration-resolution IntersectAABB path above, which caused walk-
-- through/teleport/resolve-underneath issues for a kinematic character.
-- Used for character grounding on slopes only; walls/obstacles still go
-- through normal AABB collision elsewhere.
function ConvexHull.probeWedgeGround(position, maxDistance, block)
    local size = block.Size
    local rotation = block.Rotation
    local blockPosition = block.Position

    local slopeDef = wedgeLocalPlanes[3] -- slope face
    local worldNormal = transformNormal(slopeDef.normal, size, rotation)

    local denom = -worldNormal.Y -- dot(normal, rayDir), rayDir = (0,-1,0)
    if math.abs(denom) < 1e-5 then
        return nil
    end

    local planePoint = transformPoint(slopeDef.point, blockPosition, size, rotation)
    local t = worldNormal:Dot(planePoint - position) / denom

    if t < 0 or t > maxDistance then
        return nil
    end

    local hitPoint = Vector3.new(position.X, position.Y - t, position.Z)

    local localHit = inverseTransformPoint(hitPoint, blockPosition, size, rotation)
    if localHit.X < -0.5 or localHit.X > 0.5 or localHit.Z < -0.5 or localHit.Z > 0.5 then
        return nil
    end

    return {
        normal = worldNormal,
        point = hitPoint,
        distance = t,
    }
end

return ConvexHull