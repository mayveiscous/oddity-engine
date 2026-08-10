local json = {}

local function escapeString(str)
    return '"' .. str:gsub('[%z\1-\31\\"]', function(c)
        local escapes = {
            ['"'] = '\\"',
            ['\\'] = '\\\\',
            ['\b'] = '\\b',
            ['\f'] = '\\f',
            ['\n'] = '\\n',
            ['\r'] = '\\r',
            ['\t'] = '\\t',
        }

        return escapes[c] or string.format("\\u%04x", c:byte())
    end) .. '"'
end

local function isArray(tbl)
    local count = 0

    for k in pairs(tbl) do
        if type(k) ~= "number" or k < 1 or k % 1 ~= 0 then
            return false
        end

        count = count + 1
    end

    for i = 1, count do
        if tbl[i] == nil then
            return false
        end
    end

    return true
end

local function encodeValue(value)
    local valueType = type(value)

    if value == nil then
        return "null"

    elseif valueType == "boolean" then
        return value and "true" or "false"

    elseif valueType == "number" then
        if value ~= value or value == math.huge or value == -math.huge then
            error("Cannot encode NaN or infinity")
        end

        return tostring(value)

    elseif valueType == "string" then
        return escapeString(value)

    elseif valueType == "table" then
        local result = {}

        if isArray(value) then
            for i = 1, #value do
                result[#result + 1] = encodeValue(value[i])
            end

            return "[" .. table.concat(result, ",") .. "]"
        end

        for key, val in pairs(value) do
            if type(key) ~= "string" then
                error("JSON object keys must be strings")
            end

            result[#result + 1] =
                escapeString(key) .. ":" .. encodeValue(val)
        end

        return "{" .. table.concat(result, ",") .. "}"

    else
        error("Cannot encode value of type " .. valueType)
    end
end

function json.encode(value)
    return encodeValue(value)
end


-- Decoder

local function decodeError(str, index, message)
    error("JSON error at position " .. index .. ": " .. message)
end

local function skipWhitespace(str, index)
    while true do
        local c = str:sub(index, index)

        if c == " " or c == "\t" or c == "\n" or c == "\r" then
            index = index + 1
        else
            return index
        end
    end
end

local function parseString(str, index)
    index = index + 1

    local result = {}

    while index <= #str do
        local c = str:sub(index, index)

        if c == '"' then
            return table.concat(result), index + 1
        end

        if c == "\\" then
            local escape = str:sub(index + 1, index + 1)

            local escapes = {
                ['"'] = '"',
                ['\\'] = '\\',
                ['/'] = '/',
                ['b'] = '\b',
                ['f'] = '\f',
                ['n'] = '\n',
                ['r'] = '\r',
                ['t'] = '\t',
            }

            if escapes[escape] then
                result[#result + 1] = escapes[escape]
                index = index + 2

            elseif escape == "u" then
                local hex = str:sub(index + 2, index + 5)

                if not hex:match("^%x%x%x%x$") then
                    decodeError(str, index, "Invalid Unicode escape")
                end

                local codepoint = tonumber(hex, 16)

                -- Basic UTF-8 encoding
                if codepoint < 0x80 then
                    result[#result + 1] = string.char(codepoint)

                elseif codepoint < 0x800 then
                    result[#result + 1] = string.char(
                        0xC0 + math.floor(codepoint / 0x40),
                        0x80 + codepoint % 0x40
                    )

                else
                    result[#result + 1] = string.char(
                        0xE0 + math.floor(codepoint / 0x1000),
                        0x80 + math.floor(codepoint / 0x40) % 0x40,
                        0x80 + codepoint % 0x40
                    )
                end

                index = index + 6

            else
                decodeError(str, index, "Invalid escape sequence")
            end
        else
            if c:byte() < 32 then
                decodeError(str, index, "Invalid control character")
            end

            result[#result + 1] = c
            index = index + 1
        end
    end

    decodeError(str, index, "Unterminated string")
end

local function parseNumber(str, index)
    local start = index
    
    if str:sub(index, index) == "-" then
        index = index + 1
    end

    local integerStart = index

    while str:sub(index, index):match("%d") do
        index = index + 1
    end

    if index == integerStart then
        decodeError(str, start, "Invalid number")
    end

    if str:sub(index, index) == "." then
        index = index + 1

        local fractionStart = index

        while str:sub(index, index):match("%d") do
            index = index + 1
        end

        if index == fractionStart then
            decodeError(str, start, "Invalid number")
        end
    end

    local exponent = str:sub(index, index)

    if exponent == "e" or exponent == "E" then
        index = index + 1

        local sign = str:sub(index, index)

        if sign == "+" or sign == "-" then
            index = index + 1
        end

        local exponentStart = index

        while str:sub(index, index):match("%d") do
            index = index + 1
        end

        if index == exponentStart then
            decodeError(str, start, "Invalid number")
        end
    end

    local number = str:sub(start, index - 1)
    local value = tonumber(number)

    if not value then
        decodeError(str, start, "Invalid number")
    end

    return value, index
end

local parseValue

local function parseArray(str, index)
    index = skipWhitespace(str, index + 1)

    local result = {}

    if str:sub(index, index) == "]" then
        return result, index + 1
    end

    while true do
        local value
        value, index = parseValue(str, index)

        result[#result + 1] = value

        index = skipWhitespace(str, index)

        local c = str:sub(index, index)

        if c == "]" then
            return result, index + 1
        elseif c ~= "," then
            decodeError(str, index, "Expected ',' or ']'")
        end

        index = skipWhitespace(str, index + 1)
    end
end

local function parseObject(str, index)
    index = skipWhitespace(str, index + 1)

    local result = {}

    if str:sub(index, index) == "}" then
        return result, index + 1
    end

    while true do
        if str:sub(index, index) ~= '"' then
            decodeError(str, index, "Expected object key")
        end

        local key
        key, index = parseString(str, index)

        index = skipWhitespace(str, index)

        if str:sub(index, index) ~= ":" then
            decodeError(str, index, "Expected ':'")
        end

        index = skipWhitespace(str, index + 1)

        local value
        value, index = parseValue(str, index)

        result[key] = value

        index = skipWhitespace(str, index)

        local c = str:sub(index, index)

        if c == "}" then
            return result, index + 1
        elseif c ~= "," then
            decodeError(str, index, "Expected ',' or '}'")
        end

        index = skipWhitespace(str, index + 1)
    end
end

parseValue = function(str, index)
    index = skipWhitespace(str, index)

    local c = str:sub(index, index)

    if c == '"' then
        return parseString(str, index)

    elseif c == "{" then
        return parseObject(str, index)

    elseif c == "[" then
        return parseArray(str, index)

    elseif c == "-" or c:match("%d") then
        return parseNumber(str, index)

    elseif str:sub(index, index + 3) == "true" then
        return true, index + 4

    elseif str:sub(index, index + 4) == "false" then
        return false, index + 5

    elseif str:sub(index, index + 3) == "null" then
        return nil, index + 4

    else
        decodeError(str, index, "Unexpected character")
    end
end

function json.decode(str)
    if type(str) ~= "string" then
        error("json.decode expects a string")
    end

    local value, index = parseValue(str, 1)

    index = skipWhitespace(str, index)

    if index <= #str then
        decodeError(str, index, "Unexpected trailing data")
    end

    return value
end

return json