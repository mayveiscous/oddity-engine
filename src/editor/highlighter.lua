local EditorState = require("src.editor.editor_state")
local SelectionService = require("src.classes.selectionservice")
local Gizmo = require("src.editor.gizmo")

local graphics = require("graphics")

local Highlighter = {}

function Highlighter.draw()
    local selected = SelectionService.current

    if selected and selected._meshId then
        graphics.drawMesh(
            selected._meshId,
            selected.Position.X, selected.Position.Y, selected.Position.Z,
            selected.Size.X * 1.05, selected.Size.Y * 1.05, selected.Size.Z * 1.05,
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
