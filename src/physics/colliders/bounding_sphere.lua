local Vector3 = require "src.types.vector3"

local PhysicsObject = {}
PhysicsObject.__index = PhysicsObject

local currentId = 0

local function nextId()
    currentId = currentId + 1
    return currentId
end

function PhysicsObject.new(pos, vel, collider, instance)
    local self = setmetatable({}, PhysicsObject)

    self._id = nextId()

    self.m_position = pos
    self.m_velocity = vel

    self.collider = collider
    self.instance = instance

    self.Type = "Sphere"

    self.Grounded = false

    return self
end

function PhysicsObject.fromPart(part, collider)
    return PhysicsObject.new(
        part.Position,
        Vector3.zero(),
        collider,
        part
    )
end

function PhysicsObject:GetCollider()
    return self.collider
end

function PhysicsObject:SetPosition(position)
    self.m_position = position

    if self.collider then
        if self.collider.m_center then
            self.collider.m_center = position
        end
    end
end

function PhysicsObject:Integrate(dt)
    self:SetPosition(
        self.m_position + self.m_velocity * dt
    )
end

function PhysicsObject:SyncToInstance()
    if self.instance then
        self.instance.Position = self.m_position
    end
end

return PhysicsObject