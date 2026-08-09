package.path = package.path .. ";./?.lua;./src/?.lua;"

-- route prints to the editor ui
local Log = require "src.editor.state.log"
local _originalPrint = print

function print(...)
    _originalPrint(...)
    local args = {...}
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(args[i])
    end
    Log.info(table.concat(parts, "\t"))
end

require "src.interface.init"