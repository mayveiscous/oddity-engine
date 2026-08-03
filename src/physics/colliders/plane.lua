local Vector3 = require "src.types.vector3"

local Plane = {}
Plane.__index = Plane

function Plane.new(normal, distance)
    local self = setmetatable({}, Plane)
    self.m_normal = normal
    self.m_distance = distance
    self.Type = "Plane"
    return self
end

function Plane:Normalize()
    local mag = self.m_normal.Magnitude
    return Plane.new(self.m_normal / mag, self.m_distance / mag)
end

function Plane:IntersectSphere(other)
    local heightAbovePlane = self.m_normal:Dot(other.m_center) + self.m_distance
    local distanceFromSurface = heightAbovePlane - other.m_radius

    return {
        Intersects = distanceFromSurface < 0,
        Distance = distanceFromSurface
    }
end

return Plane