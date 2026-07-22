local graphics = require("graphics")

local Output = {}

local logs = {
    "[Info] Engine started.",
    "[Info] Loaded workspace.",
    "[Warning] Missing texture."
}

function Output.draw()

    graphics.imguiBegin("Output")

    for _, line in ipairs(logs) do
        graphics.imguiText(line)
    end

    graphics.imguiEnd()

end

return Output