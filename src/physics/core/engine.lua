local Vector3 = require "src.types.vector3"

local AABB = require "src.physics.colliders.aabb"
local ConvexHull = require "src.physics.colliders.convex_hull"
local CollisionType = require "src.physics.core.resolve_collision_type"
local PhysicsObject = require "src.physics.core.physics_object"

local PhysicsEngine = {}
PhysicsEngine.registered = {}
PhysicsEngine.byInstance = {}

PhysicsEngine.Gravity = 196.2
PhysicsEngine.Restitution = 0.1
PhysicsEngine.MaxSubstep = 1 / 120  -- caps how far anything can move before a collision check runs
PhysicsEngine.MaxSubsteps = 8       -- ceiling so a lag spike can't spiral into dozens of steps
PhysicsEngine.GroundFriction = 8

local function getColliderFor(block)
    if block.collider then
        return block.collider
    end

    if block.Shape == "Wedge" then
        return ConvexHull.fromWedge(block)
    end

    return AABB.fromBlock(block)
end

local function applyWorldCollision(obj, colliders)
    local slop = 0.005
    local iterations = 4

    for _ = 1, iterations do
        local hadCollision = false

        for _, block in ipairs(colliders) do
            if block ~= obj.instance then
                local blockCollider = getColliderFor(block)
                local result = CollisionType.Test(obj.collider, blockCollider)

                if result.Intersects then
                    hadCollision = true

                    local penetration = -result.Distance

                    if penetration > slop then
                        obj.m_position = obj.m_position + result.Normal * (penetration - slop)

                        if obj.collider.Type == "AABB" then
                            obj.collider:Recenter(obj.m_position)
                        elseif obj.collider.m_center then
                            obj.collider.m_center = obj.m_position
                        end
                    end

                    local vn = obj.m_velocity:Dot(result.Normal)

                    if vn < 0 then
                        obj.m_velocity = obj.m_velocity - result.Normal * vn
                    end

                    if result.Normal.Y > 0.65 then
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

            local aIsWedge = a.instance and a.instance.Shape == "Wedge"
            local bIsWedge = b.instance and b.instance.Shape == "Wedge"

            if not aIsWedge and not bIsWedge then
                local result = CollisionType.Test(a.collider, b.collider)

                if result.Intersects then
                    local delta = b.m_position - a.m_position
                    local dist = delta.Magnitude
                    local normal = result.Normal

                    local penetration = -result.Distance
                    local correction = (normal * (penetration / 2)) / 2
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
end

local function applyWedgeGroundProbe(obj, colliders)
    if not obj.collider or not obj.collider.half then
        return
    end

    local feetY = obj.m_position.Y - obj.collider.half.Y
    local feetPos = Vector3.new(obj.m_position.X, feetY, obj.m_position.Z)

    local probeDistance = math.max(0.5, obj.collider.half.Y)

    local best = nil

    for _, block in ipairs(colliders) do
        if block ~= obj.instance and block.Shape == "Wedge" then
            local hit = ConvexHull.probeWedgeGround(feetPos, probeDistance, block)

            if hit and (not best or hit.distance < best.distance) then
                best = hit
            end
        end
    end

    if not best then
        return
    end

    if obj.m_velocity.Y <= 0.5 then
        local newFeetY = best.point.Y
        obj.m_position = Vector3.new(obj.m_position.X, newFeetY + obj.collider.half.Y, obj.m_position.Z)
        obj.collider:Recenter(obj.m_position)

        obj.Grounded = true
        obj.m_velocity = Vector3.new(obj.m_velocity.X, 0, obj.m_velocity.Z)
    end
end

local function simulateObject(obj, colliders, subDt)
    local wasGrounded = obj.Grounded
    obj.Grounded = false

    if not wasGrounded then
        obj.m_velocity = obj.m_velocity - Vector3.new(0, PhysicsEngine.Gravity * subDt, 0)
    end

    obj:Integrate(subDt)
    applyWorldCollision(obj, colliders)
    applyWedgeGroundProbe(obj, colliders)

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
            if obj.collider.Type == "AABB" then
                obj.collider:Recenter(obj.m_position)
            else
                obj.collider.m_center = obj.m_position
            end
            simulateObject(obj, colliders, subDt)
        end
        PhysicsEngine:HandleCollisions()
    end

    for _, obj in pairs(PhysicsEngine.registered) do
        obj:SyncToInstance()
    end
end

function PhysicsObject.fromPart(part)
    return PhysicsObject.new(part.Position, Vector3.new(0, 0, 0), AABB.fromBlock(part), part)
end

function PhysicsEngine.ResolveDragPosition(inst, desiredPosition, colliders)
    local obj = PhysicsEngine.GetObjectForInstance(inst)

    if not obj then
        return desiredPosition
    end

    local position = desiredPosition

    for _ = 1, 4 do
        local collided = false

        obj.m_position = position
        obj.collider:Recenter(position)

        for _, block in ipairs(colliders or {}) do
            if block ~= inst then
                local blockCollider = getColliderFor(block)
                local result = CollisionType.Test(obj.collider, blockCollider)

                if result.Intersects then
                    local penetration = -result.Distance

                    if penetration > 0 then
                        position = position + result.Normal * penetration
                        collided = true
                    end
                end
            end
        end

        if not collided then
            break
        end
    end

    return position
end

function PhysicsEngine.GetContact(inst, colliders)
    local obj = PhysicsEngine.GetObjectForInstance(inst)

    if not obj then
        return nil
    end

    for _, block in ipairs(colliders or {}) do
        if block ~= inst then
            local blockCollider = getColliderFor(block)
            local result = CollisionType.Test(obj.collider, blockCollider)

            if result.Intersects then
                return {
                    Instance = block,
                    Normal = result.Normal,
                    Distance = result.Distance,
                }
            end
        end
    end

    return nil
end

return PhysicsEngine