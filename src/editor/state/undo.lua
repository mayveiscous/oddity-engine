local EditorState = require "src.editor.state"

local MAX_HISTORY = 100

local UndoStack = {}

local undoList = {}
local redoList = {}

local function validate(action)
    assert(type(action) == "table", "UndoStack.Push expects a table")
    assert(type(action.undo) == "function", "action.undo must be a function")
    assert(type(action.redo) == "function", "action.redo must be a function")
end

function UndoStack.Push(action)
    if EditorState.isPlaytesting then
        return
    end

    validate(action)

    table.insert(undoList, action)
    if #undoList > MAX_HISTORY then
        table.remove(undoList, 1)
    end

    redoList = {}
end

function UndoStack.Undo()
    local action = table.remove(undoList)
    if not action then
        return false
    end

    action.undo()
    table.insert(redoList, action)
    return true
end

function UndoStack.Redo()
    local action = table.remove(redoList)
    if not action then
        return false
    end

    action.redo()
    table.insert(undoList, action)
    return true
end

function UndoStack.CanUndo()
    return #undoList > 0
end

function UndoStack.CanRedo()
    return #redoList > 0
end

function UndoStack.Clear()
    undoList = {}
    redoList = {}
end

return UndoStack
