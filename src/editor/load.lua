local Explorer = require "src.editor.interfaces.explorer"
local Inspector = require "src.editor.interfaces.inspector"
local Output = require "src.editor.interfaces.output"
local TopBar = require "src.editor.interfaces.top_bar"
local AnimationEditor = require "src.editor.interfaces.animation_editor"
local Layout = require "src.editor.state.layout"
local InputService = require "src.classes.services.inputservice"
local TextEditor = require "src.editor.interfaces.text_editor"
local Theme = require "src.editor.interfaces.theme"
local UndoStack = require "src.editor.state.undo"
local SelectionService = require "src.classes.services.selectionservice"
local KBM = require "src.editor.state.keybinds"

local ui = require "src.core.ui"

local EditorState = require "src.editor.state"

local graphics = require "oddity.graphics"
local hasApplied = false

local function draw(workspace)
    if not hasApplied then
        Theme.apply()
    end

    InputService.Update()
    KBM.poll()

    EditorState.Typing = ui.wantTextInput()

    local rects = Layout.apply(EditorState.collapsed)

    Explorer.drawExplorer(workspace, rects.Explorer)
    Inspector.drawInspector(rects.Inspector)
    Output.draw(rects.Output)
    TopBar.draw(rects.TopBar)
    AnimationEditor.draw()
    TextEditor.draw(rects)

    EditorState.collapsed.Explorer = graphics.imguiWindowCollapsed("Explorer")
    EditorState.collapsed.Inspector = graphics.imguiWindowCollapsed("Inspector")
    EditorState.collapsed.Output = graphics.imguiWindowCollapsed("Output")
    EditorState.collapsed.TopBar = graphics.imguiWindowCollapsed("Top Bar")
end

KBM.ToolChange:Connect(function(new)
    if not EditorState.AttentionFocusedTo("TextEditor") then
        EditorState.CurrentTool = new
    end
end)

KBM.DuplicatePressed:Connect(function()
    if not EditorState.Typing then
        for _, inst in ipairs(SelectionService.GetAll()) do
            inst:Duplicate()
        end
    end
end)

KBM.UndoPressed:Connect(function()
    UndoStack.Undo()
end)

KBM.RedoPressed:Connect(function()
    UndoStack.Redo()
end)

KBM.Delete:Connect(function()
    if not EditorState.Typing then
        for _, inst in ipairs(SelectionService.GetAll()) do
            inst:Destroy()
        end

        SelectionService.Clear()
    end
end)

return {
    draw = draw
}