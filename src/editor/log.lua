local Log = {}

local entries = {}
local MAX_ENTRIES = 1000

function Log.info(msg)
    table.insert(entries, { level = "info", message = tostring(msg), time = os.clock() })
    if #entries > MAX_ENTRIES then
        table.remove(entries, 1)
    end
end

function Log.warn(msg)
    table.insert(entries, { level = "warn", message = tostring(msg), time = os.clock() })
    if #entries > MAX_ENTRIES then
        table.remove(entries, 1)
    end
end

function Log.error(msg)
    table.insert(entries, { level = "error", message = tostring(msg), time = os.clock() })
    if #entries > MAX_ENTRIES then
        table.remove(entries, 1)
    end
end

function Log.getEntries()
    return entries
end

function Log.clear()
    entries = {}
end

return Log