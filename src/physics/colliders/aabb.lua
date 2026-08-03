local Vector3 = require "src.types.vector3"

local AABB = {}
AABB.__index = AABB

function AABB.new(min, max)
    local self = setmetatable({}, AABB)
    self.min = min
    self.max = max
    self.half = (max - min) / 2
    self.Type = "AABB"
    return self
end

function AABB:Recenter(center)
    self.min = center - self.half
    self.max = center + self.half
end

function AABB.fromBlock(block)
    local half = block.Size / 2
    return AABB.new(block.Position - half, block.Position + half)
end

local function clamp(x, lo, hi)
    if x < lo then return lo end
    if x > hi then return hi end
    return x
end

function AABB:ClosestPoint(point)
    return Vector3.new(
        clamp(point.X, self.min.X, self.max.X),
        clamp(point.Y, self.min.Y, self.max.Y),
        clamp(point.Z, self.min.Z, self.max.Z)
    )
end

function AABB:Intersect(other)
    local dist1 = other.min - self.max
    local dist2 = self.min - other.max
    local biggestDist = Vector3.Max(dist1, dist2)

    return {
        Intersects = biggestDist.Magnitude < 0,
        Distance = biggestDist.Magnitude
    }
end

function AABB:IntersectSphere(sphere)
    local closest = Vector3.new(
        math.max(self.min.X, math.min(sphere.m_center.X, self.max.X)),
        math.max(self.min.Y, math.min(sphere.m_center.Y, self.max.Y)),
        math.max(self.min.Z, math.min(sphere.m_center.Z, self.max.Z))
    )

    local delta = sphere.m_center - closest
    local distance = delta.Magnitude

    local intersects = distance < sphere.m_radius

    if not intersects then
        return {
            Intersects = false,
            Distance = 0,
            Normal = Vector3.zero()
        }
    end

    local normal

    if distance > 0 then
        normal = delta / distance
    else
        normal = Vector3.new(0, 1, 0)
    end

    return {
        Intersects = true,
        Distance = distance - sphere.m_radius,
        Normal = normal
    }
end

function AABB:Overlap(other)
    if self.max.X <= other.min.X or self.min.X >= other.max.X then return { Intersects = false } end
    if self.max.Y <= other.min.Y or self.min.Y >= other.max.Y then return { Intersects = false } end
    if self.max.Z <= other.min.Z or self.min.Z >= other.max.Z then return { Intersects = false } end

    local overlapX = math.min(self.max.X, other.max.X) - math.max(self.min.X, other.min.X)
    local overlapY = math.min(self.max.Y, other.max.Y) - math.max(self.min.Y, other.min.Y)
    local overlapZ = math.min(self.max.Z, other.max.Z) - math.max(self.min.Z, other.min.Z)

    local selfCenter = (self.min + self.max) / 2
    local otherCenter = (other.min + other.max) / 2

    local normal, penetration
    if overlapX <= overlapY and overlapX <= overlapZ then
        normal, penetration = Vector3.new((selfCenter.X < otherCenter.X) and -1 or 1, 0, 0), overlapX
    elseif overlapY <= overlapZ then
        normal, penetration = Vector3.new(0, (selfCenter.Y < otherCenter.Y) and -1 or 1, 0), overlapY
    else
        normal, penetration = Vector3.new(0, 0, (selfCenter.Z < otherCenter.Z) and -1 or 1), overlapZ
    end

    return { Intersects = true, Normal = normal, Distance = -penetration }
end

return AABB