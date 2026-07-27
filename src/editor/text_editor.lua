local graphics = require "graphics"

local TextEditor = {}

local text = [[
print("Hello World")
]]

function TextEditor.draw()

    graphics.imguiBegin("Script Editor")

    text = graphics.imguiInputTextMultiline(
        "##editor",
        text
    )

    graphics.imguiEnd()

end

return TextEditor