local SelectionService = require "src.classes.services.selectionservice"
local InsertObject = require "src.editor.interfaces.insert_object"
local InputService = require "src.classes.services.inputservice"
local ui = require "src.core.ui"

local expanded = {}

local insertSearch = ""
local renameBuffer = ""

local renameInstance = nil
local openRenamePopup = false
local renameFocus = false

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

local function drawInsertPanel(instance)
    insertSearch = ui.inputText(
        "##insert_search_" .. instance.UniqueId,
        insertSearch
    )

    local query = insertSearch:lower()

    for _, entry in ipairs(InsertObject.Catalog) do
        if query == "" or entry.label:lower():find(query, 1, true) then
            local hit = ui.selectable(
                entry.label ..
                "##insert_item_" ..
                instance.UniqueId ..
                "_" ..
                entry.label
            )

            if hit then
                InsertObject.CreateEntry(entry, instance)
                insertSearch = ""
                ui.closeCurrentPopup()
            end
        end
    end
end

local function drawContextPanel(instance)
    if ui.selectable("Rename##ctx_rename_" .. instance.UniqueId) then
        renameBuffer = instance.Name
        renameInstance = instance
        renameFocus = true
        openRenamePopup = true

        ui.closeCurrentPopup()
    end

    if ui.selectable(
        "Delete##ctx_delete_" .. instance.UniqueId
    ) then
        local ownedSelection = ownsSelection(instance)

        instance:Destroy()

        if ownedSelection then
            SelectionService.Clear()
        end

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

    renameBuffer = ui.inputText(
        "##rename",
        renameBuffer
    )

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

local function drawNode(instance)
    local label = instance.Name .. "###" .. instance.UniqueId
    local selected = SelectionService.current == instance

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

    local open, clicked, rightClicked = ui.treeNodeEx(
        label,
        selected,
        fOpen,
        isLeaf
    )

    if not isLeaf then
        expanded[instance.UniqueId] = open
    end

    if clicked then
        SelectionService.Select(instance)
    end

    local insertId = "insert_popup_" .. instance.UniqueId
    local contextId = "context_popup_" .. instance.UniqueId

    if rightClicked then
        SelectionService.Select(instance)
        ui.openPopup(contextId)
    end

    ui.sameLine()

    if ui.smallButton("+##insert_toggle_" .. instance.UniqueId) then
        insertSearch = ""
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
            drawNode(child)
        end

        ui.treePop()
    end
end

local function drawExplorer(game, rect)
    ui.setNextWindowPos(rect.x, rect.y)
    ui.setNextWindowSize(rect.w, rect.h)

    ui.beginWindow("Explorer", {"NoMove"})

    drawNode(game.Workspace)
    drawNode(game.Lighting)
    drawNode(game.Players)
    drawNode(game.ServerScripts)
    drawNode(game.ServerStorage)
    drawNode(game.LocalStorage)

    if openRenamePopup then
        ui.openPopup("rename_popup")
        openRenamePopup = false
    end

    -- Rename popup
    if ui.beginPopup("rename_popup") then
        drawRenamePanel()
        ui.endPopup()
    end

    ui.endWindow()
end

return {
    drawExplorer = drawExplorer,

    getSelected = function()
        return SelectionService.current
    end
}
