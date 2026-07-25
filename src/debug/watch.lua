local Watch = {}

local values = {}

function Watch.add(name, getter)
    values[name] = getter
end

function Watch.getAll()
    local output = {}

    for name,getter in pairs(values) do
        output[name] = getter()
    end

    return output
end

return Watch