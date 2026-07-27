local Vector3 = require "src.types.vector3"
local AABB = require "src.physics.rewrite.colliders.aabb"

local PhysicsEngine = {}
PhysicsEngine.registered = {}
PhysicsEngine.byInstance = {}

PhysicsEngine.Gravity = 196.2
PhysicsEngine.Restitution = 0.1
PhysicsEngine.MaxSubstep = 1 / 120  -- caps how far anything can move before a collision check runs
PhysicsEngine.MaxSubsteps = 8       -- ceiling so a lag spike can't spiral into dozens of steps
PhysicsEngine.GroundFriction = 8

local function applyWorldCollision(obj, colliders)
    local slop = 0.005
    local iterations = 4

    for _ = 1, iterations do
        local hadCollision = false

        for _, block in ipairs(colliders) do
            if block ~= obj.instance then
                local result = obj:GetAABB():Overlap(AABB.fromBlock(block))

                if result.Intersects then
                    hadCollision = true

                    local penetration = -result.Distance

                    if penetration > slop then
                        obj.m_position =
                            obj.m_position +
                            result.Normal * (penetration - slop)
                    end

                    -- Remove velocity into the surface
                    local vn = obj.m_velocity:Dot(result.Normal)

                    if vn < 0 then
                        obj.m_velocity =
                            obj.m_velocity -
                            result.Normal * vn
                    end

                    if result.Normal.Y > 0.7 then
                        obj.Grounded = true

                        if obj.m_velocity.Y < 0 then
                            obj.m_velocity = Vector3.new(
                                obj.m_velocity.X,
                                0,
                                obj.m_velocity.Z
                            )
                        end
                    end
                end
            end
        end

        if not hadCollision then
            break
        end
    end
end


function PhysicsEngine.AddObject(obj)
    PhysicsEngine.registered[obj._id] = obj
    if obj.instance then
        PhysicsEngine.byInstance[obj.instance] = obj
    end
end

function PhysicsEngine.RemoveObject(obj)
    PhysicsEngine.registered[obj._id] = nil
    if obj.instance then
        PhysicsEngine.byInstance[obj.instance] = nil
    end
end

function PhysicsEngine.Clear()
    PhysicsEngine.registered = {}
    PhysicsEngine.byInstance = {}
end

function PhysicsEngine.GetObjectForInstance(instance)
    return PhysicsEngine.byInstance[instance]
end

function PhysicsEngine:HandleCollisions()
    local objs = {}
    for _, obj in pairs(PhysicsEngine.registered) do
        objs[#objs + 1] = obj
    end

    for i = 1, #objs - 1 do
        for j = i + 1, #objs do
            local a, b = objs[i], objs[j]
            local result = a:GetAABB():Intersect(b:GetAABB())

            if result.Intersects then
                local delta = b.m_position - a.m_position
                local dist = delta.Magnitude
                local normal = (dist > 1e-6) and (delta / dist) or Vector3.new(0, 1, 0)

                local penetration = -result.Distance
                local correction = normal * (penetration / 2)
                a.m_position = a.m_position - correction
                b.m_position = b.m_position + correction

                local approachSpeed = (b.m_velocity - a.m_velocity):Dot(normal)
                if approachSpeed < 0 then
                    local impulse = normal * (approachSpeed * (1 + PhysicsEngine.Restitution))
                    a.m_velocity = a.m_velocity + impulse
                    b.m_velocity = b.m_velocity - impulse
                end
            end
        end
    end
end

local function simulateObject(obj, colliders, subDt)
    obj.Grounded = false
    obj.m_velocity = obj.m_velocity - Vector3.new(0, PhysicsEngine.Gravity * subDt, 0)
    obj:Integrate(subDt)
    applyWorldCollision(obj, colliders)

    if obj.Grounded then
        local decay = math.max(0, 1 - PhysicsEngine.GroundFriction * subDt)
        obj.m_velocity = Vector3.new(
            obj.m_velocity.X * decay,
            obj.m_velocity.Y,
            obj.m_velocity.Z * decay
        )
    end
end

function PhysicsEngine.Simulate(dt, colliders)
    colliders = colliders or {}

    local steps = math.min(PhysicsEngine.MaxSubsteps, math.max(1, math.ceil(dt / PhysicsEngine.MaxSubstep)))
    local subDt = dt / steps

    for _ = 1, steps do
        for _, obj in pairs(PhysicsEngine.registered) do
            simulateObject(obj, colliders, subDt)
        end
        PhysicsEngine:HandleCollisions()
    end

    for _, obj in pairs(PhysicsEngine.registered) do
        obj:SyncToInstance()
    end
end

return PhysicsEngine