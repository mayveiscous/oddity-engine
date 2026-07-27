local graphics = require "graphics"
local Log = require "src.editor.log"

local Output = {}

local prefixes = {
    info = "         ",
    warn = "[WARN]   ",
    error = "[ERROR] ",
}

function Output.draw(rects)
    graphics.imguiSetNextWindowPos(rects.x, rects.y)
    graphics.imguiSetNextWindowSize(rects.w, rects.h)
    graphics.imguiBegin("Output", {"NoMove"})

    if graphics.imguiButton("Clear") then
        Log.clear()
    end

    graphics.imguiSeparator()

    for _, entry in ipairs(Log.getEntries()) do
        local prefix = prefixes[entry.level] or ""
        graphics.imguiSelectable(prefix .. entry.message)
    end

    graphics.imguiEnd()
end

return Output