local Vector3 = require "src.types.vector3"

local Math = {}

function Math.dot(a, b)
    return a.X * b.X + a.Y * b.Y + a.Z * b.Z
end

function Math.cross(a, b)
    return Vector3.new(
        a.Y * b.Z - a.Z * b.Y,
        a.Z * b.X - a.X * b.Z,
        a.X * b.Y - a.Y * b.X
    )
end

function Math.length(v)
    return math.sqrt(v.X^2 + v.Y^2 + v.Z^2)
end

function Math.normalize(v)
    local length = Math.length(v)

    if length < 1e-6 then
        return Vector3.new(0, 0, 0)
    end

    return Vector3.new(
        v.X / length,
        v.Y / length,
        v.Z / length
    )
end

function Math.getMouseRay(mx, my, graphics)
    local ox, oy, oz, dx, dy, dz = graphics.screenPointToRay(mx, my)

    return Vector3.new(ox, oy, oz), Math.normalize(Vector3.new(dx, dy, dz))
end

function Math.rayPlaneIntersection(rayOrigin, rayDirection, planePoint, planeNormal)
    local denominator = Math.dot(rayDirection, planeNormal)

    if math.abs(denominator) < 1e-6 then
        return nil
    end

    local t = Math.dot(planePoint - rayOrigin, planeNormal) / denominator

    return rayOrigin + rayDirection * t
end

function Math.getAxisPosition(axis, mx, my, planePoint, planeNormal, graphics)
    local rayOrigin, rayDirection = Math.getMouseRay(mx, my, graphics)

    local hit = Math.rayPlaneIntersection(rayOrigin, rayDirection, planePoint, planeNormal)

    if not hit then
        return nil
    end

    return Math.dot(hit, axis.direction)
end

function Math.getAxisDragPlane(axis, rayDirection)
    local perpendicular = Math.cross(rayDirection, axis.direction)

    if Math.length(perpendicular) < 1e-4 then
        local fallback

        if math.abs(axis.direction.Y) < 0.9 then
            fallback = Vector3.new(0, 1, 0)
        else
            fallback = Vector3.new(1, 0, 0)
        end

        perpendicular = Math.cross(fallback, axis.direction)
    end

    return Math.normalize(Math.cross(axis.direction, perpendicular))
end

function Math.getAxisHalfSize(size, axis)
    if axis.direction.X ~= 0 then
        return size.X / 2
    elseif axis.direction.Y ~= 0 then
        return size.Y / 2
    else
        return size.Z / 2
    end
end

function Math.getAxisCenter(position, axis)
    return Math.dot(position, axis.direction)
end

function Math.getAxisExtents(position, size, axis)
    local half = Math.getAxisHalfSize(size, axis)
    local center = Math.getAxisCenter(position, axis)

    return center - half, center + half, center
end

function Math.projectOntoPlane(vector, normal)
    return vector - normal * Math.dot(vector, normal)
end

function Math.getSurfaceBasis(rayDirection, surfaceNormal)
    local right = Math.cross(rayDirection, surfaceNormal)

    if Math.length(right) < 1e-6 then
        return nil, nil
    end

    right = Math.normalize(right)

    local up = Math.normalize(
        Math.cross(surfaceNormal, right)
    )

    return right, up
end

return Math