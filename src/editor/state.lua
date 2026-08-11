local Tabs = require "src.editor.state.tabs"

local EditorState = {}

EditorState.CurrentTool = "Select" -- Select | Move | Scale | Rotate
EditorState.isPlaytesting = false -- are we in a playtest, should we compute physics, spawn characters, etc.
EditorState.collapsed = {}
EditorState.returnTo = nil
EditorState.AttentionFocus = "Editor"
EditorState.Typing = false

function EditorState.AttentionFocusedTo(focus)
    return ((EditorState.AttentionFocus:lower()) == (focus:lower()))
end

function EditorState.IsTyping()
    return EditorState.Typing
end

function EditorState.StartPlaytest()
    EditorState.returnTo = Tabs.getActiveIndex()
    EditorState.isPlaytesting = true
end

function EditorState.StopPlaytest()
    if EditorState.returnTo ~= nil then
        Tabs.setActiveIndex(EditorState.returnTo)
    end
    EditorState.isPlaytesting = false
end

return EditorState