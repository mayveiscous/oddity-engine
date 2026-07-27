local Explorer = require "src.editor.explorer"
local Inspector = require "src.editor.inspector"
local Output = require "src.editor.output"
local TopBar = require "src.editor.top_bar"
local AnimationEditor = require "src.editor.animation_editor"
local Layout = require "src.editor.layout"
local InputService = require "src.classes.inputservice"
local Theme = require "src.editor.theme"

local EditorState = require "src.editor.editor_state"

local graphics = require "graphics"
local hasApplied = false

local function draw(workspace)
    if not hasApplied then
        Theme.apply()
    end
    
    local rects = Layout.apply(EditorState.collapsed)

    Explorer.drawExplorer(workspace, rects.Explorer)
    Inspector.drawInspector(rects.Inspector)
    Output.draw(rects.Output)
    TopBar.draw(rects.TopBar)
    AnimationEditor.draw()

    EditorState.collapsed.Explorer = graphics.imguiWindowCollapsed("Explorer")
    EditorState.collapsed.Inspector = graphics.imguiWindowCollapsed("Inspector")
    EditorState.collapsed.Output = graphics.imguiWindowCollapsed("Output")
    EditorState.collapsed.TopBar = graphics.imguiWindowCollapsed("Top Bar")

    if InputService.IsKeyDown("One") then
        EditorState.CurrentTool = "Select"
    elseif InputService.IsKeyDown("Two") then
        EditorState.CurrentTool = "Move"
    end
end

return {
    draw = draw
}