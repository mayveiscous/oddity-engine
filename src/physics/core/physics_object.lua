local Vector3 = require "src.types.vector3"
local AABB = require "src.physics.colliders.aabb"

local PhysicsObject = {}
PhysicsObject.__index = PhysicsObject

local currentId = 0
local function nextId() currentId = currentId + 1 return currentId end

function PhysicsObject.new(pos, vel, size, instance)
    local self = setmetatable({}, PhysicsObject)
    self._id = nextId()
    self.m_position = pos
    self.m_velocity = vel
    self.m_size = size
    self.instance = instance
    self.Grounded = false
    return self
end

function PhysicsObject.fromPart(part)
    return PhysicsObject.new(part.Position, Vector3.new(0, 0, 0), part.Size, part)
end

function PhysicsObject:GetAABB()
    local half = self.m_size / 2
    return AABB.new(self.m_position - half, self.m_position + half)
end

function PhysicsObject:Integrate(dt)
    self.m_position = self.m_position + self.m_velocity * dt
end

function PhysicsObject:SyncToInstance()
    if self.instance then
        self.instance.Position = self.m_position
    end
end

return PhysicsObject