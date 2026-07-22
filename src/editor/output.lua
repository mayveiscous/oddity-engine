local graphics = require("graphics")
local Layout = require("src.editor.layout")

local Output = {}

local logs = {
    "[Info] Engine started.",
    "[Info] Loaded workspace.",
    --"[Warning] Missing texture."
}

function Output.draw(rects)
    graphics.imguiSetNextWindowPos(rects.x, rects.y)
    graphics.imguiSetNextWindowSize(rects.w, rects.h)
    graphics.imguiBegin("Output", {"NoMove"})

    for _, line in ipairs(logs) do
        graphics.imguiText(line)
    end

    graphics.imguiEnd()

end

return Output