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

    self.Grounded = false

    return self
end

function PhysicsObject:GetSphere()
    return {
        m_center = self.m_position,
        m_radius = self.collider.radius
    }
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