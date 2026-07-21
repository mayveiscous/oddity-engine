local render = require("render")

local AnimationEditor = {}

function AnimationEditor.draw()

    render.imguiBegin("Animation Editor")

    render.imguiText("Animation")

    render.imguiSeparator()

    render.imguiButton("Play")
    render.imguiSameLine()
    render.imguiButton("Pause")
    render.imguiSameLine()
    render.imguiButton("Stop")

    render.imguiSeparator()

    render.imguiText("Timeline")

    render.imguiEnd()

end

return AnimationEditor