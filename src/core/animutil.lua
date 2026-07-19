local Vector3 = require("src.types.vector3")

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function rotateVector3(v, eulerDeg)
    local function rad(d) return d * math.pi / 180 end

    local x, y, z = v.X, v.Y, v.Z
    
    --z
    local rz = rad(eulerDeg.Z)
    local cz, sz = math.cos(rz), math.sin(rz)
    x, y = x * cz - y * sz, x * sz + y * cz

    --x
    local rx = rad(eulerDeg.X)
    local cx, sx = math.cos(rx), math.sin(rx)
    y, z = y * cx - z * sx, y * sx + z * cx

    --y
    local ry = rad(eulerDeg.Y)
    local cy, sy = math.cos(ry), math.sin(ry)
    x, z = x * cy + z * sy, -x * sy + z * cy

    return Vector3.new(x, y, z)
end

local function lerpVector3(a, b, t)
    return Vector3.new(
        lerp(a.X, b.X, t),
        lerp(a.Y, b.Y, t),
        lerp(a.Z, b.Z, t)
    )
end

local function sampleTrack(track, time)
    for i = 1, #track - 1 do
        local kf0, kf1 = track[i], track[i + 1]
        if time >= kf0.time and time <= kf1.time then
            local span = kf1.time - kf0.time
            local t = span > 0 and (time - kf0.time) / span or 0
            return lerpVector3(kf0.rotation, kf1.rotation, t)
        end
    end
    return track[#track].rotation
end

return { lerp = lerp, lerpVector3 = lerpVector3, sampleTrack = sampleTrack, rotateVector3 = rotateVector3 }