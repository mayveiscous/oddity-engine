local EditorState = require "src.editor.state"
local SelectionService = require "src.classes.services.selectionservice"
local Gizmo = require "src.editor.state.gizmo"

local graphics = require "oddity.graphics"

local Highlighter = {}

local outlineThickness = 1.10

function Highlighter.draw()
    if EditorState.isPlaytesting then
        return
    end

    local selected = SelectionService.current

    if selected and selected._meshId then
        graphics.drawSelectionOutline(
            selected._meshId,
            selected.Position.X,
            selected.Position.Y,
            selected.Position.Z,
            selected.Size.X,
            selected.Size.Y,
            selected.Size.Z,
            selected.Rotation.X,
            selected.Rotation.Y,
            selected.Rotation.Z,
            outlineThickness,
            1,
            0,
            0,
            1
        )

        if EditorState.CurrentTool == "Move" then
            Gizmo.draw(selected._meshId)
        end
    end
end

return Highlighter