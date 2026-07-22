local Explorer = require("src.editor.explorer")
local Inspector = require("src.editor.inspector")
local Output = require("src.editor.output")
local TopBar = require("src.editor.top_bar")
local AnimationEditor = require("src.editor.animation_editor")
local Layout = require("src.editor.layout")

local graphics = require("graphics")

local collapsed = {}

local function draw(workspace)
    local rects = Layout.apply(collapsed)

    Explorer.drawExplorer(workspace, rects.Explorer)
    Inspector.drawInspector(rects.Inspector)
    Output.draw(rects.Output)
    TopBar.draw(rects.TopBar)
    AnimationEditor.draw()

    collapsed.Explorer = graphics.imguiWindowCollapsed("Explorer")
    collapsed.Inspector = graphics.imguiWindowCollapsed("Inspector")
    collapsed.Output = graphics.imguiWindowCollapsed("Output")
    collapsed.TopBar = graphics.imguiWindowCollapsed("Top Bar")
end

return {
    draw = draw
}