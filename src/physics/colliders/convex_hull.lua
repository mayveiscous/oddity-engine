local Vector3 = require "src.types.vector3"

local ConvexHull = {}

local function buildMeta(planes)
    local self = {}
    self.normalized = {}

    for i, plane in ipairs(planes) do
        local norm = plane:Normalize()
        self.normalized[i] = norm
    end

    self.Type = "ConvexHull"

    return self
end

function ConvexHull.new(planes)
    return setmetatable(buildMeta(planes), ConvexHull)
end

function ConvexHull:IntersectSphere(sphere)
    local bestDistance = 0
    local bestPlane = nil

    for _, plane in ipairs(self.normalized) do
        local result = plane:IntersectSphere(sphere)

        if result.Intersects then
            if not bestPlane or result.Distance < bestDistance then
                bestDistance = result.Distance
                bestPlane = plane
            end
        end
    end

    if not bestPlane then
        return {
            Intersects = false,
            Distance = 0,
            Normal = Vector3.zero()
        }
    end

    return {
        Intersects = true,
        Distance = bestDistance,
        Normal = bestPlane.m_normal
    }
end

return ConvexHull