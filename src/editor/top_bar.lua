local render = require("render")

local TopBar = {}

function TopBar.draw()

    if render.imguiBeginMainMenuBar() then

        if render.imguiBeginMenu("File") then
            render.imguiMenuItem("New")
            render.imguiMenuItem("Open")
            render.imguiMenuItem("Save")
            render.imguiEndMenu()
        end

        if render.imguiBeginMenu("Edit") then
            render.imguiMenuItem("Undo")
            render.imguiMenuItem("Redo")
            render.imguiEndMenu()
        end

        if render.imguiBeginMenu("View") then
            render.imguiMenuItem("Explorer")
            render.imguiMenuItem("Properties")
            render.imguiMenuItem("Output")
            render.imguiEndMenu()
        end

        if render.imguiBeginMenu("Test") then
            render.imguiMenuItem("Play")
            render.imguiMenuItem("Stop")
            render.imguiEndMenu()
        end

        render.imguiEndMainMenuBar()
    end

end

return TopBar