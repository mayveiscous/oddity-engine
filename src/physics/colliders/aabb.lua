local Vector3 = require "src.types.vector3"

local AABB = {}
AABB.__index = AABB

function AABB.new(min, max)
    local self = setmetatable({}, AABB)
    self.min = min
    self.max = max
    return self
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
    local closest = self:ClosestPoint(sphere.m_center)
    local diff = sphere.m_center - closest
    local dist = diff.Magnitude

    if dist >= sphere.m_radius then
        return { Intersects = false }
    end

    local normal = (dist > 1e-6) and (diff / dist) or Vector3.new(0, 1, 0)

    return {
        Intersects = true,
        Normal = normal,
        Distance = dist - sphere.m_radius
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