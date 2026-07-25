local Keyframe = {}
Keyframe.__index = Keyframe

local function buildMeta()
    return {
        __index = function(t, k)
            local state = rawget(t, "_state")

            local v = state[k]
            if v ~= nil then
                return v
            end

            return Keyframe[k]
        end,

        __newindex = function(t, k, v)
            local state = rawget(t, "_state")

            if k ~= "Time" and
               k ~= "Value" and
               k ~= "Interpolation" and
               k ~= "EasingStyle" and
               k ~= "EasingDirection" then
                error(("Keyframe has no member '%s'"):format(k))
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
            return ("Keyframe(%g)"):format(s.Time)
        end
    }
end

function Keyframe.new(time, value)
    local self = setmetatable({}, buildMeta())

    rawset(self, "_state", {
        Time = time or 0,
        Value = value,
        Interpolation = "Linear",
        EasingStyle = "Linear",
        EasingDirection = "InOut",
        _owner = nil,
        _key = nil,
        _isKeyframe = true
    })

    return self
end

function Keyframe._bind(keyframe, owner, key)
    local state = rawget(keyframe, "_state")
    state._owner = owner
    state._key = key
end

return Keyframe