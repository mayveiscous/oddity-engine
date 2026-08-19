local Log = require "src.editor.state.log"
local ui = require "src.core.ui"

local Output = {}

local prefixes = {
    info = "         ",
    warn = "[WARN]   ",
    error = "[ERROR] ",
}

function Output.draw()
    ui.beginWindow("Output")

    if ui.button("Clear") then
        Log.clear()
    end

    ui.separator()

    for _, entry in ipairs(Log.getEntries()) do
        local prefix = prefixes[entry.level] or ""
        ui.selectable(prefix .. entry.message)
    end

    ui.endWindow()
end

return Output