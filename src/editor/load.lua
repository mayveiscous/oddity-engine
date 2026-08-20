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

local lastDockW, lastDockH = nil, nil

local function draw(workspace)
    if not hasApplied then
        Theme.apply()
    end

    InputService.Update()
    KBM.poll()

    EditorState.Typing = ui.wantTextInput()

    if not ui.wantsMouse() then
        EditorState.AttentionFocus = "Renderer"
    end

    local rects = Layout.apply(EditorState.collapsed)

    local dockId = ui.dockSpace("MainDockspace", rects.Dock.x, rects.Dock.y, rects.Dock.w, rects.Dock.h)

    local sizeChanged = lastDockW ~= nil and (
        math.abs(rects.Dock.w - lastDockW) > 0.5 or
        math.abs(rects.Dock.h - lastDockH) > 0.5
    )

    if not ui.dockBuilderNodeExists(dockId) or sizeChanged then
        ui.dockBuilderReset(dockId, rects.Dock.w, rects.Dock.h)

        local rightId, leftoverId = ui.dockBuilderSplit(dockId, "Right", rects.PanelWidth / rects.Dock.w)
        local explorerId, inspectorId = ui.dockBuilderSplit(rightId, "Up", rects.ExplorerHeightRatio)
        local outputId = ui.dockBuilderSplit(leftoverId, "Down", rects.OutputHeight / rects.Dock.h)

        ui.dockBuilderDockWindow("Explorer", explorerId)
        ui.dockBuilderDockWindow("Properties", inspectorId)
        ui.dockBuilderDockWindow("Output", outputId)

        ui.dockBuilderFinish(dockId)
    end

    lastDockW, lastDockH = rects.Dock.w, rects.Dock.h

    Explorer.drawExplorer(workspace)
    Output.draw()
    TopBar.draw(rects.TopBar)
    AnimationEditor.draw()
    TextEditor.draw(rects)

    Inspector.drawInspector()

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
        local deleted = false
        for _, inst in ipairs(SelectionService.GetAll()) do
            if not inst.IsCoreService and inst.CanBeDeleted then
                deleted = true
                inst:Destroy()
            end
        end

        if not deleted then return end
        SelectionService.Clear()
    end
end)

return {
    draw = draw
}