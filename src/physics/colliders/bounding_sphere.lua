local Vector3 = require "src/types/vector3"

local BoundingSphere = {}
BoundingSphere.__index = BoundingSphere

function BoundingSphere.new(position, radius)
    local self = setmetatable({}, BoundingSphere)

    self.m_center = position
    self.m_radius = radius

    return self
end

function BoundingSphere:Intersect(other)
    local radDist = self.m_radius + other.m_radius
    local centDistance = (self.m_center - other.m_center).Magnitude

    local intersects = false

    if centDistance < radDist then
        intersects = true
    end

    return {
        Intersects = intersects,
        Distance = (centDistance - radDist)
    }
end

return BoundingSphere