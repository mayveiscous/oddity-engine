local Instance = require "src.core.instance"

local Internal = {}

function Internal.SetProperty(instance, propertyName, value)
    local state = rawget(instance, "_state")
    local old = state[propertyName]

    state[propertyName] = value

    if old ~= value and state.Changed then
        state.Changed:Fire(propertyName, value)
    end
end

return Internal