local Shapes = {}

Shapes.Block = {
    -0.5,-0.5,-0.5, 0,0,-1, 0,0,   0.5,-0.5,-0.5, 0,0,-1, 1,0,   0.5,0.5,-0.5, 0,0,-1, 1,1,
     0.5,0.5,-0.5, 0,0,-1, 1,1,  -0.5,0.5,-0.5, 0,0,-1, 0,1,  -0.5,-0.5,-0.5, 0,0,-1, 0,0,
    -0.5,-0.5,0.5, 0,0,1, 0,0,    0.5,-0.5,0.5, 0,0,1, 1,0,    0.5,0.5,0.5, 0,0,1, 1,1,
     0.5,0.5,0.5, 0,0,1, 1,1,   -0.5,0.5,0.5, 0,0,1, 0,1,   -0.5,-0.5,0.5, 0,0,1, 0,0,
    -0.5,0.5,0.5, -1,0,0, 1,1,   -0.5,0.5,-0.5, -1,0,0, 0,1,  -0.5,-0.5,-0.5, -1,0,0, 0,0,
    -0.5,-0.5,-0.5, -1,0,0, 0,0, -0.5,-0.5,0.5, -1,0,0, 1,0,  -0.5,0.5,0.5, -1,0,0, 1,1,
     0.5,0.5,0.5, 1,0,0, 1,1,     0.5,0.5,-0.5, 1,0,0, 0,1,    0.5,-0.5,-0.5, 1,0,0, 0,0,
     0.5,-0.5,-0.5, 1,0,0, 0,0,   0.5,-0.5,0.5, 1,0,0, 1,0,    0.5,0.5,0.5, 1,0,0, 1,1,
    -0.5,-0.5,-0.5, 0,-1,0, 0,0,  0.5,-0.5,-0.5, 0,-1,0, 1,0,  0.5,-0.5,0.5, 0,-1,0, 1,1,
     0.5,-0.5,0.5, 0,-1,0, 1,1,  -0.5,-0.5,0.5, 0,-1,0, 0,1,  -0.5,-0.5,-0.5, 0,-1,0, 0,0,
    -0.5,0.5,-0.5, 0,1,0, 0,0,    0.5,0.5,-0.5, 0,1,0, 1,0,    0.5,0.5,0.5, 0,1,0, 1,1,
     0.5,0.5,0.5, 0,1,0, 1,1,   -0.5,0.5,0.5, 0,1,0, 0,1,   -0.5,0.5,-0.5, 0,1,0, 0,0,
}

Shapes.Wedge = (function()
    local A = {-0.5,-0.5,-0.5} -- bottom-back-left
    local B = { 0.5,-0.5,-0.5} -- bottom-back-right
    local C = {-0.5,-0.5, 0.5} -- bottom-front-left
    local D = { 0.5,-0.5, 0.5} -- bottom-front-right
    local E = {-0.5, 0.5,-0.5} -- top-back-left
    local F = { 0.5, 0.5,-0.5} -- top-back-right

    local v = {}
    local function push(p, n, u, uv)
        table.insert(v, p[1]); table.insert(v, p[2]); table.insert(v, p[3])
        table.insert(v, n[1]); table.insert(v, n[2]); table.insert(v, n[3])
        table.insert(v, u); table.insert(v, uv)
    end

    -- bottom face
    local nDown = {0,-1,0}
    push(A,nDown,0,0) push(C,nDown,0,1) push(D,nDown,1,1)
    push(A,nDown,0,0) push(D,nDown,1,1) push(B,nDown,1,0)

    -- back face (vertical)
    local nBack = {0,0,-1}
    push(A,nBack,0,0) push(E,nBack,0,1) push(F,nBack,1,1)
    push(A,nBack,0,0) push(F,nBack,1,1) push(B,nBack,1,0)

    -- sloped face — normal points up and forward, 45 degrees
    local nSlope = {0, 0.7071, 0.7071}
    push(C,nSlope,0,0) push(F,nSlope,1,1) push(E,nSlope,0,1)
    push(C,nSlope,0,0) push(D,nSlope,1,0) push(F,nSlope,1,1)

    -- left triangular face
    local nLeft = {-1,0,0}
    push(A,nLeft,0,0) push(C,nLeft,1,0) push(E,nLeft,0,1)

    -- right triangular face
    local nRight = {1,0,0}
    push(B,nRight,0,0) push(F,nRight,0,1) push(D,nRight,1,0)

    return v
end)()

local function pointAt(theta, phi)
    local x = math.sin(theta) * math.cos(phi)
    local y = math.cos(theta)
    local z = math.sin(theta) * math.sin(phi)
    return x, y, z
end

function Shapes.generateSphere(rings, segments)
    rings = rings or 12
    segments = segments or 16
    local radius = 0.5
    local v = {}

    local function push(x, y, z, u, uv)
        table.insert(v, x * radius)
        table.insert(v, y * radius)
        table.insert(v, z * radius)
        table.insert(v, x)
        table.insert(v, y)
        table.insert(v, z)
        table.insert(v, u)
        table.insert(v, uv)
    end

    for r = 0, rings - 1 do
        local theta1 = math.pi * r / rings
        local theta2 = math.pi * (r + 1) / rings
        for s = 0, segments - 1 do
            local phi1 = 2 * math.pi * s / segments
            local phi2 = 2 * math.pi * (s + 1) / segments

            local x1,y1,z1 = pointAt(theta1, phi1)
            local x2,y2,z2 = pointAt(theta1, phi2)
            local x3,y3,z3 = pointAt(theta2, phi1)
            local x4,y4,z4 = pointAt(theta2, phi2)

            local u1 = phi1 / (2 * math.pi)
            local u2 = phi2 / (2 * math.pi)
            local v1 = 1 - theta1 / math.pi
            local v2 = 1 - theta2 / math.pi

            push(x1,y1,z1,u1,v1) push(x3,y3,z3,u1,v2) push(x4,y4,z4,u2,v2)
            push(x1,y1,z1,u1,v1) push(x4,y4,z4,u2,v2) push(x2,y2,z2,u2,v1)
        end
    end

    return v
end

return Shapes
