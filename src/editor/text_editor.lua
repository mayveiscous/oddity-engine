local render = require("render")

local TextEditor = {}

local text = [[
print("Hello World")
]]

function TextEditor.draw()

    render.imguiBegin("Script Editor")

    text = render.imguiInputTextMultiline(
        "##editor",
        text
    )

    render.imguiEnd()

end

return TextEditor