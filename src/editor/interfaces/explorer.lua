local SelectionService = require "src.classes.services.selectionservice"
local InsertObject = require "src.editor.interfaces.insert_object"
local InputService = require "src.classes.services.inputservice"
local ui = require "src.core.ui"

local EditorState = require "src.editor.state"
local TextEditor = require "src.editor.interfaces.text_editor"

local expanded = {}

local insertSearch = ""
local renameBuffer = ""

local renameInstance = nil
local openRenamePopup = false

local renameFocus = false
local insertFocus = false

local pendingInsertInstance = nil

local explorerRoot = nil

local selectionAnchor = nil

local lastClickInstance = nil
local lastClickTime = 0

local DOUBLE_CLICK_TIME = 0.3

local function shouldExpand(instance)
    local selected = SelectionService.current

    if not selected then
        return false
    end

    if selected == instance then
        return true
    end

    for _, ancestor in ipairs(selected:GetAncestors()) do
        if ancestor == instance then
            return true
        end
    end

    return false
end

local function findInstanceById(root, id)
    if tostring(root.UniqueId) == id then
        return root
    end

    for _, child in ipairs(root:GetChildren()) do
        local found = findInstanceById(child, id)

        if found then
            return found
        end
    end

    return nil
end

local function canReparent(instance, newParent)
    if instance == newParent then
        return false
    end

    for _, ancestor in ipairs(newParent:GetAncestors()) do
        if ancestor == instance then
            return false
        end
    end

    return true
end

local function ownsSelection(instance)
    local sel = SelectionService.current

    if not sel then
        return false
    end

    if sel == instance then
        return true
    end

    for _, ancestor in ipairs(sel:GetAncestors()) do
        if ancestor == instance then
            return true
        end
    end

    return false
end

local function collectVisibleInstances(instance, result)
    table.insert(result, instance)

    if not expanded[instance.UniqueId] then
        return
    end

    for _, child in ipairs(instance:GetChildren()) do
        collectVisibleInstances(child, result)
    end
end

local function getVisibleInstances(game)
    local result = {}

    collectVisibleInstances(game.Workspace, result)
    collectVisibleInstances(game.Lighting, result)
    collectVisibleInstances(game.Players, result)
    collectVisibleInstances(game.ServerScripts, result)
    collectVisibleInstances(game.ServerStorage, result)
    collectVisibleInstances(game.LocalStorage, result)
    collectVisibleInstances(game.ClientScripts, result)
    collectVisibleInstances(game.PlayerScripts, result)
    collectVisibleInstances(game.SoundStorage, result)

    return result
end

local function selectRange(game, from, to)
    local visible = getVisibleInstances(game)

    local fromIndex = nil
    local toIndex = nil

    for i, instance in ipairs(visible) do
        if instance == from then
            fromIndex = i
        end

        if instance == to then
            toIndex = i
        end
    end

    if not fromIndex or not toIndex then
        SelectionService.Select(to)
        return
    end

    if fromIndex > toIndex then
        fromIndex, toIndex = toIndex, fromIndex
    end

    SelectionService.Clear()

    for i = fromIndex, toIndex do
        SelectionService.Add(visible[i])
    end
end

local function handleSelectionClick(game, instance)
    local ctrl = InputService.IsKeyDown("LeftControl") or InputService.IsKeyDown("RightControl")
    local shift = InputService.IsKeyDown("LeftShift") or InputService.IsKeyDown("RightShift")

    if shift and selectionAnchor then
        selectRange(game, selectionAnchor, instance)
        return
    end

    if ctrl then
        SelectionService.Toggle(instance)
        selectionAnchor = instance
        return
    end

    SelectionService.Select(instance)
    selectionAnchor = instance
end

local function handleDoubleClick(instance)
    local now = os.clock()

    local isDoubleClick = lastClickInstance == instance and now - lastClickTime <= DOUBLE_CLICK_TIME

    lastClickInstance = instance
    lastClickTime = now

    if not isDoubleClick then
        return
    end

    if instance:IsA("LuaScript") then
        TextEditor.openScript(instance)
    end

    lastClickInstance = nil
    lastClickTime = 0
end

local function drawInsertPanel(instance)
    if insertFocus then
        ui.setKeyboardFocusHere()
        insertFocus = false
    end

    insertSearch = ui.inputText("##insert_search_" .. instance.UniqueId, insertSearch)

    local query = insertSearch:lower()
    local firstMatch = nil

    for _, entry in ipairs(InsertObject.Catalog) do
        if query == "" or entry.label:lower():find(query, 1, true) then
            if not firstMatch then
                firstMatch = entry
            end

            local hit = ui.selectable(entry.label .. "##insert_item_" .. instance.UniqueId .. "_" .. entry.label)

            if hit then
                InsertObject.CreateEntry(entry, instance)
                insertSearch = ""
                ui.closeCurrentPopup()
                return
            end
        end
    end

    if InputService.IsKeyPressed("Enter") and firstMatch then
        InsertObject.CreateEntry(firstMatch, instance)
        insertSearch = ""
        ui.closeCurrentPopup()
    end
end

local function drawContextPanel(instance)
    if ui.selectable("Add##ctx_add_" .. instance.UniqueId) then
        insertSearch = ""
        insertFocus = true
        pendingInsertInstance = instance
        ui.closeCurrentPopup()
    end

    if ui.selectable("Rename##ctx_rename_" .. instance.UniqueId) then
        renameBuffer = instance.Name
        renameInstance = instance
        renameFocus = true
        openRenamePopup = true

        ui.closeCurrentPopup()
    end

    if ui.selectable("Delete##ctx_delete_" .. instance.UniqueId) then
        local ownedSelection = ownsSelection(instance)

        instance:Destroy()

        if ownedSelection then
            SelectionService.Clear()
            selectionAnchor = nil
        end

        ui.closeCurrentPopup()
    end

    if ui.selectable("Duplicate##ctx_duplicate_" .. instance.UniqueId) then
        local dup = instance:Duplicate()

        SelectionService.Clear()
        SelectionService.Select(dup)

        selectionAnchor = dup

        ui.closeCurrentPopup()
    end
end

local function drawRenamePanel()
    local instance = renameInstance

    if not instance then
        ui.closeCurrentPopup()
        return
    end

    if renameFocus then
        ui.setKeyboardFocusHere()
        renameFocus = false
    end

    renameBuffer = ui.inputText("##rename", renameBuffer)

    if InputService.IsKeyPressed("Enter") then
        if renameBuffer ~= "" then
            instance.Name = renameBuffer
        end

        renameBuffer = ""
        renameInstance = nil

        ui.closeCurrentPopup()

    elseif InputService.IsKeyPressed("Esc") then
        renameBuffer = ""
        renameInstance = nil

        ui.closeCurrentPopup()
    end
end

local function drawNode(instance, game)
    local label = instance.Name .. "###" .. instance.UniqueId
    local selected = SelectionService.Contains(instance)

    local hasChild = #instance:GetChildren() > 0

    local forceOpen = false

    if hasChild then
        forceOpen = shouldExpand(instance)

        if forceOpen then
            expanded[instance.UniqueId] = true
        end
    end

    local fOpen = hasChild and expanded[instance.UniqueId] == true
    local isLeaf = not hasChild
    local isCore = instance.IsCoreService

    local open, clicked, rightClicked = ui.treeNodeEx(label, selected, fOpen, not hasChild, isCore)

    if not instance.IsCoreService then
        if ui.beginDragDropSource() then
            ui.setDragDropPayload("ODDITY_INSTANCE", tostring(instance.UniqueId))

            ui.text(instance.Name)

            ui.endDragDropSource()
        end
    end

    if ui.beginDragDropTarget() then
        local draggedId = ui.acceptDragDropPayload("ODDITY_INSTANCE")

        if draggedId then
            local dragged = findInstanceById(explorerRoot, draggedId)

            if dragged and canReparent(dragged, instance) then
                dragged.Parent = instance
            end
        end

        ui.endDragDropTarget()
    end

    if not isLeaf then
        expanded[instance.UniqueId] = open
    end

    if clicked then
        handleSelectionClick(game, instance)
        handleDoubleClick(instance)
    end

    local insertId = "insert_popup_" .. instance.UniqueId
    local contextId = "context_popup_" .. instance.UniqueId

    if rightClicked then
        SelectionService.Select(instance)
        selectionAnchor = instance

        ui.openPopup(contextId)
    end

    ui.sameLine()

    if ui.smallButton("+##insert_toggle_" .. instance.UniqueId) then
        insertSearch = ""
        insertFocus = true
        ui.openPopup(insertId)
    end

    if ui.beginPopup(insertId) then
        drawInsertPanel(instance)
        ui.endPopup()
    end

    if ui.beginPopup(contextId) then
        drawContextPanel(instance)
        ui.endPopup()
    end

    if open then
        for _, child in ipairs(instance:GetChildren()) do
            drawNode(child, game)
        end

        ui.treePop()
    end
end

local function drawExplorer(game)
    explorerRoot = game

    ui.beginWindow("Explorer")

    if ui.isWindowHovered() then
        EditorState.AttentionFocus = "Explorer"
    end

    drawNode(game.Workspace, game)
    drawNode(game.Lighting, game)
    drawNode(game.Players, game)
    drawNode(game.ServerScripts, game)
    drawNode(game.ServerStorage, game)
    drawNode(game.LocalStorage, game)
    drawNode(game.ClientScripts, game)
    drawNode(game.PlayerScripts, game)
    drawNode(game.SoundStorage, game)

    if openRenamePopup then
        ui.openPopup("rename_popup")
        openRenamePopup = false
    end

    if ui.beginPopup("rename_popup") then
        drawRenamePanel()
        ui.endPopup()
    end

    if pendingInsertInstance then
        local instance = pendingInsertInstance
        pendingInsertInstance = nil

        ui.openPopup("insert_popup_" .. instance.UniqueId)
    end

    ui.endWindow()
end


return {
    drawExplorer = drawExplorer,

    getSelected = function()
        return SelectionService.current
    end
}