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

local EditorState = require "src.editor.state"

local graphics = require "graphics"
local hasApplied = false

local function handleShortcuts()
    local ctrl = InputService.IsKeyDown("LeftControl") or InputService.IsKeyDown("RightControl")

    if ctrl and InputService.IsKeyPressed("Z") then
        UndoStack.Undo()
    elseif ctrl and InputService.IsKeyPressed("Y") then
        UndoStack.Redo()
    end

    if InputService.IsKeyPressed("Delete") then
        for _, inst in ipairs(SelectionService.GetAll()) do
            inst:Destroy()
        end
        SelectionService.Clear()
    end
end

local function draw(workspace)
    if not hasApplied then
        Theme.apply()
    end

    InputService.Update()

    if InputService.IsKeyDown("One") then
        EditorState.CurrentTool = "Select"
    elseif InputService.IsKeyDown("Two") then
        EditorState.CurrentTool = "Move"
    elseif InputService.IsKeyDown("Three") then
        EditorState.CurrentTool = "Scale"
    elseif InputService.IsKeyDown("Four") then
        EditorState.CurrentTool = "Rotate"
    end

    if not EditorState.isPlaytesting and not graphics.imguiWantsKeyboard() then
        handleShortcuts()
    end

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

return {
    draw = draw
}