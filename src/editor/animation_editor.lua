local graphics = require("graphics")

local AnimationEditor = {}

function AnimationEditor.draw()

    graphics.imguiBegin("Animation Editor")

    graphics.imguiText("Animation")

    graphics.imguiSeparator()

    graphics.imguiButton("Play")
    graphics.imguiSameLine()
    graphics.imguiButton("Pause")
    graphics.imguiSameLine()
    graphics.imguiButton("Stop")

    graphics.imguiSeparator()

    graphics.imguiText("Timeline")

    graphics.imguiEnd()

end

return AnimationEditor