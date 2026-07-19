local Color3 = {}
Color3.__index = Color3

local function buildMeta()
    return {
        __index = function(t, k)
            local state = rawget(t, "_state")
            local v = state[k]
            if v ~= nil then return v end
            return Color3[k]
        end,

        __newindex = function(t, k, v)
            local state = rawget(t, "_state")
            if k ~= "R" and k ~= "G" and k ~= "B" then
                error(("Color3 has no member '%s'"):format(k))
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
            return ("Color3(%g, %g, %g)"):format(s.R, s.G, s.B)
        end
    }
end

function Color3.new(r, g, b)
    local self = setmetatable({}, buildMeta())
    rawset(self, "_state", { R = r or 0, G = g or 0, B = b or 0, _owner = nil, _key = nil, _isColor3 = true })
    return self
end

function Color3._bind(vec, owner, key)
    local state = rawget(vec, "_state")
    state._owner = owner
    state._key = key
end

function Color3.__add(a, b)
    return Color3.new(a.R + b.R, a.G + b.G, a.B + b.B)
end

return Color3