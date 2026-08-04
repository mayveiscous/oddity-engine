local EditorState = {}

EditorState.CurrentTool = "Select" -- Select | Move | Scale | Rotate
EditorState.isPlaytesting = false -- are we in a playtest, should we compute physics, spawn characters, etc.
EditorState.collapsed = {}

function EditorState.StartPlaytest()
    EditorState.isPlaytesting = true
end

function EditorState.StopPlaytest()
    EditorState.isPlaytesting = false
end

return EditorState