local Vector2 = {}
Vector2.__index = Vector2

local function buildMeta()
    return {
        __index = function(t, k)
            local state = rawget(t, "_state")
            local v = state[k]
            if v ~= nil then return v end
            return Vector2[k]
        end,

        __newindex = function(t, k, v)
            local state = rawget(t, "_state")
            if k ~= "X" and k ~= "Y" then
                error(("Vector2 has no member '%s'"):format(k))
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
            return ("Vector2(%g, %g)"):format(s.X, s.Y)
        end
    }
end

function Vector2.new(x, y)
    local self = setmetatable({}, buildMeta())
    rawset(self, "_state", { X = x or 0, Y = y or 0, _owner = nil, _key = nil, _isVector2 = true })
    return self
end

function Vector2._bind(vec, owner, key)
    local state = rawget(vec, "_state")
    state._owner = owner
    state._key = key
end

function Vector2.__add(a, b)
    return Vector2.new(a.X + b.X, a.Y + b.Y)
end

return Vector2