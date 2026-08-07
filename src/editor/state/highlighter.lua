local EditorState = require "src.editor.state"
local SelectionService = require "src.classes.selectionservice"
local Gizmo = require "src.editor.state.gizmo"

local graphics = require "graphics"

local Highlighter = {}

local outlineThickness = 1.03

function Highlighter.draw()
    if EditorState.isPlaytesting then return end
    local selected = SelectionService.current

    if selected and selected._meshId then
        graphics.drawMesh(
            selected._meshId,
            selected.Position.X, selected.Position.Y, selected.Position.Z,
            selected.Size.X * outlineThickness, selected.Size.Y * outlineThickness, selected.Size.Z * outlineThickness,
            1, 0.8, 0,
            selected.Rotation.X, selected.Rotation.Y, selected.Rotation.Z,
            1,
            "gizmo_highlight"
        )

        if EditorState.CurrentTool == "Move" then
            Gizmo.draw(selected._meshId)
        end
    end
end

return Highlighter