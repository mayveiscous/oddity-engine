local graphics = require("graphics")
local AnimationEditor = require("src.editor.animation_editor")

local TopBar = {}

local currentTool = "Select"
local playing = false

function TopBar.draw(rects)
    graphics.imguiSetNextWindowPos(rects.x, rects.y)
    graphics.imguiSetNextWindowSize(rects.w, rects.h)

    if graphics.imguiBegin("Top Bar", {"NoMove", "NoResize", "MenuBar"}) then
        if graphics.imguiBeginMenuBar() then
            if graphics.imguiBeginMenu("File") then
                if graphics.imguiMenuItem("New") then
                    print("New project")
                end

                if graphics.imguiMenuItem("Save") then
                    print("Save project")
                end

                graphics.imguiEndMenu()
            end


            if graphics.imguiBeginMenu("Edit") then
                graphics.imguiMenuItem("Undo")
                graphics.imguiMenuItem("Redo")

                if graphics.imguiMenuItem("Animation Editor") then
                    AnimationEditor.toggle()
                end

                graphics.imguiEndMenu()
            end


            graphics.imguiEndMenuBar()
        end


        graphics.imguiSeparator()


        local tools = {
            "Select",
            "Move",
            "Scale",
            "Rotate"
        }

        for _, tool in ipairs(tools) do
            if graphics.imguiButtonEx(tool, currentTool == tool, 70, 24) then
                currentTool = tool
            end

            graphics.imguiSameLine()
        end

    end

    graphics.imguiEnd()
end

return TopBar