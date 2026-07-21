local Vector3 = {}
Vector3.__index = Vector3

local function buildMeta()
    return {
        __index = function(t, k)
            local state = rawget(t, "_state")

            if k == "Magnitude" then
                return math.sqrt(state.X^2 + state.Y^2 + state.Z^2)
            end

            if k == "Unit" then
                local mag = math.sqrt(state.X^2 + state.Y^2 + state.Z^2)
                if mag == 0 then
                    return Vector3.new(0, 0, 0)
                end

                return Vector3.new(state.X / mag, state.Y / mag, state.Z / mag)
            end

            local v = state[k]
            if v ~= nil then return v end
            return Vector3[k]
        end,

        __newindex = function(t, k, v)
            local state = rawget(t, "_state")
            if k ~= "X" and k ~= "Y" and k ~= "Z" then
                error(("Vector3 has no member '%s'"):format(k))
            end

            local old = state[k]
            state[k] = v

            if old ~= v then
                local owner = state._owner
                local key = state._key
                if owner then
                    owner.Changed:Fire(key, t)
                end
            end
        end,

        __add = function(a, b)
            return Vector3.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
        end,

        __sub = function(a, b)
            return Vector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
        end,

        __mul = function(a, b)
            if type(b) == "number" then
                return Vector3.new(
                    a.X * b,
                    a.Y * b,
                    a.Z * b
                )
            end

            return Vector3.new(
                a.X * b.X,
                a.Y * b.Y,
                a.Z * b.Z
            )   
        end,

        __div = function(a, b)
            if type(b) == "number" then
                return Vector3.new(
                    a.X / b,
                    a.Y / b,
                    a.Z / b
                )
            end

            return Vector3.new(
                a.X / b.X,
                a.Y / b.Y,
                a.Z / b.Z
            )
        end,

        __unm = function(a)
            return Vector3.new(-a.X, -a.Y, -a.Z)
        end,

        __tostring = function(t)
            local s = rawget(t, "_state")
            return ("Vector3(%g, %g, %g)"):format(s.X, s.Y, s.Z)
        end
    }
end

function Vector3.new(x, y, z)
    local self = setmetatable({}, buildMeta())
    rawset(self, "_state", { X = x or 0, Y = y or 0, Z = z or 0, _owner = nil, _key = nil, _isVector3 = true })
    return self
end

function Vector3.zero()
    local self = setmetatable({}, buildMeta())
    rawset(self, "_state", {X = 0, Y = 0, Z = 0, _owner = nil, _key = nil, _isVector3 = true })
    return self
end

function Vector3:Lerp(goal, alpha)
    return Vector3.new(
        self.X + (goal.X - self.X) * alpha,
        self.Y + (goal.Y - self.Y) * alpha,
        self.Z + (goal.Z - self.Z) * alpha
    )
end

function Vector3._bind(vec, owner, key)
    local state = rawget(vec, "_state")
    state._owner = owner
    state._key = key
end

setmetatable(Vector3, {
    __index = function(t, k)
        if k == "Zero" then
            return Vector3.new(0, 0, 0)
        end

        if k == "One" then 
            return Vector3.new(1, 1, 1)
        end
    end
})

return Vector3