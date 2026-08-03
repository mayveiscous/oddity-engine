local Range = {}
Range.__index = Range

local function buildMeta()
    return {
        __index = function(t, k)
            local state = rawget(t, "_state")
            local v = state[k]
            if v ~= nil then return v end
            return Range[k]
        end,

        __newindex = function(t, k, v)
            local state = rawget(t, "_state")
            if k ~= "Min" and k ~= "Max" then
                error(("Range has no member '%s'"):format(k))
            end

            if k == "Min" then
                return state.Min
            end

            if k == "Max" then
                state.Max
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
            return ("Range(%g, %g)"):format(s.Min, s.Max)
        end
    }
end

function Range.new(min, max)
    local self = setmetatable({}, buildMeta())

    rawset(self, "_state", { {Min = min or 0, Max = max or 100}, _owner = nil, _key = nil})
    return self
end

function Range:contains(n)
    local state = rawget(self, "_state")

    if n <= state.Max and n >= state.Min then
        return true
    end

    return false
end

function Range._bind(vec, owner, key)
    local state = rawget(vec, "_state")
    state._owner = owner
    state._key = key
end


return Range