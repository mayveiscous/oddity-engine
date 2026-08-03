local Collision = {}

function Collision.Test(a, b)
    assert(a, "A doesn't exist")
    assert(b, "B doesn't exist")

    if a.Type == "AABB" and b.Type == "AABB" then
        return a:Overlap(b)

    elseif a.Type == "Sphere" and b.Type == "AABB" then
        return b:IntersectSphere(a)

    elseif a.Type == "AABB" and b.Type == "Sphere" then
        local result = a:IntersectSphere(b)

        result.Normal = -result.Normal

        return result

    elseif a.Type == "Sphere" and b.Type == "ConvexHull" then
        return b:IntersectSphere(a)

    elseif a.Type == "ConvexHull" and b.Type == "Sphere" then
        local result = a:IntersectSphere(b)

        result.Normal = -result.Normal

        return result
    end

    error("No collision handler for " .. a.Type .. " and " .. b.Type)
end

return Collision