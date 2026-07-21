local render = require("render")

local Output = {}

local logs = {
    "[Info] Engine started.",
    "[Info] Loaded workspace.",
    "[Warning] Missing texture."
}

function Output.draw()

    render.imguiBegin("Output")

    for _, line in ipairs(logs) do
        render.imguiText(line)
    end

    render.imguiEnd()

end

return Output