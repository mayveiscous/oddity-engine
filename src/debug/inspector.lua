local Inspect = {}

local function serialize(value, depth)
    depth = depth or 0

    local indent = string.rep("    ", depth)

    if type(value) ~= "table" then
        return tostring(value)
    end


    local result = "{\n"

    for k,v in pairs(value) do
        result = result ..
            indent ..
            "    " ..
            tostring(k) ..
            " = " ..
            serialize(v, depth + 1) ..
            "\n"
    end

    result = result .. indent .. "}"

    return result
end

function Inspect.dump(value)
    print(serialize(value))
end

return Inspect