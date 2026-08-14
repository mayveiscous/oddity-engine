local Vector3 = require "src.types.vector3"

local Sphere = {}
Sphere.__index = Sphere

function Sphere.new(center, radius)
    local self = setmetatable({}, Sphere)
    self.m_center = center
    self.m_radius = radius
    self.Type = "Sphere"
    return self
end

function Sphere:Recenter(center)
    self.m_center = center
end

-- radius approximated as the largest half-extent, since blocks aren't spherical
function Sphere.fromBlock(block)
    local half = block.Size / 2
    local radius = math.max(half.X, half.Y, half.Z)
    return Sphere.new(block.Position, radius)
end

function Sphere:Overlap(other)
    local delta = other.m_center - self.m_center
    local dist = delta.Magnitude
    local radiusSum = self.m_radius + other.m_radius

    if dist >= radiusSum then
        return { Intersects = false }
    end

    local normal
    if dist > 0 then
        normal = delta / dist
    else
        normal = Vector3.new(0, 1, 0)
    end

    return {
        Intersects = true,
        Normal = normal,
        Distance = -(radiusSum - dist), -- matches AABB:Overlap's negative-penetration convention
    }
end

return Sphere