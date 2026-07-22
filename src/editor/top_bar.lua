local graphics = require("graphics")

local TopBar = {}

function TopBar.draw()

    if graphics.imguiBeginMainMenuBar() then

        if graphics.imguiBeginMenu("File") then
            graphics.imguiMenuItem("New")
            graphics.imguiMenuItem("Open")
            graphics.imguiMenuItem("Save")
            graphics.imguiEndMenu()
        end

        if graphics.imguiBeginMenu("Edit") then
            graphics.imguiMenuItem("Undo")
            graphics.imguiMenuItem("Redo")
            graphics.imguiEndMenu()
        end

        if graphics.imguiBeginMenu("View") then
            graphics.imguiMenuItem("Explorer")
            graphics.imguiMenuItem("Properties")
            graphics.imguiMenuItem("Output")
            graphics.imguiEndMenu()
        end

        if graphics.imguiBeginMenu("Test") then
            graphics.imguiMenuItem("Play")
            graphics.imguiMenuItem("Stop")
            graphics.imguiEndMenu()
        end

        graphics.imguiEndMainMenuBar()
    end

end

return TopBar