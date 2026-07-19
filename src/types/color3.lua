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
    
    if r > 1 then
        r = r / 255
    end

    if g > 1 then
        g = g / 255
    end

    if b > 1 then
        b = b / 255
    end

    rawset(self, "_state", { R = r or 0, G = g or 0, B = b or 0, _owner = nil, _key = nil, _isColor3 = true })
    return self
end

function Color3.fromHex(hex)
    local self = setmetatable({}, buildMeta())

    hex = hex:gsub("#", "")
    assert(#hex == 6, "Expected a h")

    local r = (tonumber(hex:sub(1, 2), 16) / 255)
    local g = (tonumber(hex:sub(3, 4), 16) / 255)
    local b = (tonumber(hex:sub(5, 6), 16) / 255)

    rawset(self, "_state", {R=r, G=g,B=b,_owner=nil,_key=nil,_isColor3=true})
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