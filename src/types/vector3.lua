local Vector3 = {}
Vector3.__index = Vector3

local function buildMeta()
    return {
        __index = function(t, k)
            local state = rawget(t, "_state")
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

function Vector3._bind(vec, owner, key)
    local state = rawget(vec, "_state")
    state._owner = owner
    state._key = key
end

function Vector3.__add(a, b)
    return Vector3.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end

return Vector3