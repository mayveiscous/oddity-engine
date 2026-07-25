local Logger = {}

local levels = {
    INFO = "INFO",
    WARN = "WARN",
    ERROR = "ERROR"
}

local function timestamp()
    return os.date("%H:%M:%S")
end

local function write(level, ...)
    local args = {...}

    local message = ""
    for _, v in ipairs(args) do
        message = message .. tostring(v) .. " "
    end

    print(string.format(
        "[%s][%s] %s",
        timestamp(),
        level,
        message
    ))
end


function Logger.info(...)
    write(levels.INFO, ...)
end

function Logger.warn(...)
    write(levels.WARN, ...)
end

function Logger.error(...)
    write(levels.ERROR, ...)
end


return Logger