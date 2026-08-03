local SelectionService = require "src.classes.selectionservice"
local Layout = require "src.editor.layout"
local InsertObject = require "src.editor.insert_object"
local InputService = require "src.classes.inputservice"

local graphics = require "graphics"

local expanded = {}

local panelForId = nil
local insertSearch = ""
local renameBuffer = ""

local function closePanel()
    panelMode = nil
    panelForId = nil
    insertSearch = ""
    renameBuffer = ""
end

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
    if not sel then return false end
    if sel == instance then return true end

    for _, ancestor in ipairs(sel:GetAncestors()) do
        if ancestor == instance then return true end
    end

    return false
end

local function drawInsertPanel(instance)
    local newText = graphics.imguiInputText("##insert_search_" .. instance.UniqueId, insertSearch)
    insertSearch = newText

    local query = insertSearch:lower()

    for _, entry in ipairs(InsertObject.Catalog) do
        if query == "" or entry.label:lower():find(query, 1, true) then
            local hit = graphics.imguiSelectable(
                entry.label .. "##insert_item_" .. instance.UniqueId .. "_" .. entry.label
            )

            if hit then
                InsertObject.CreateEntry(entry, instance)
                closePanel()
            end
        end
    end

    graphics.imguiSeparator()
end

local function drawContextPanel(instance)
    if graphics.imguiSelectable("Rename##ctx_rename_" .. instance.UniqueId) then
        renameBuffer = instance.Name
        panelMode = "rename"
        -- panelForId stays the same, just switching what's shown for it
    end

    if graphics.imguiSelectable("Delete##ctx_delete_" .. instance.UniqueId) then
        local ownedSelection = ownsSelection(instance)

        instance:Destroy()

        if ownedSelection then
            SelectionService.Clear()
        end

        closePanel()
    end

    graphics.imguiSeparator()
end

local function drawRenamePanel(instance)
    renameBuffer = graphics.imguiInputText("##rename_" .. instance.UniqueId, renameBuffer)

    if InputService.IsKeyDown("Enter") then
        if renameBuffer ~= "" then
            instance.Name = renameBuffer
        end
        closePanel()
    elseif InputService.IsKeyDown("Esc") then
        closePanel()
    end

    graphics.imguiSeparator()
end

local function drawNode(instance)
    local label = instance.Name .. " (" .. instance.ClassName .. ")"

    local selected = (SelectionService.current == instance)

    local forceOpen = shouldExpand(instance)

    local open, clicked, rightClicked = graphics.imguiTreeNodeEx(
        label,
        selected,
        forceOpen
    )

    if clicked then
        SelectionService.Select(instance)
    end

    if rightClicked then
        SelectionService.Select(instance)

        if panelForId == instance.UniqueId and panelMode == "context" then
            closePanel()
        else
            panelMode = "context"
            panelForId = instance.UniqueId
        end
    end

    graphics.imguiSameLine()
    if graphics.imguiSmallButton("+##insert_toggle_" .. instance.UniqueId) then
        if panelForId == instance.UniqueId and panelMode == "insert" then
            closePanel()
        else
            panelMode = "insert"
            panelForId = instance.UniqueId
            insertSearch = ""
        end
    end

    if panelForId == instance.UniqueId then
        if panelMode == "insert" then
            drawInsertPanel(instance)
        elseif panelMode == "context" then
            drawContextPanel(instance)
        elseif panelMode == "rename" then
            drawRenamePanel(instance)
        end
    end

    if open then
        for _, child in ipairs(instance:GetChildren()) do
            drawNode(child)
        end

        graphics.imguiTreePop()
    end
end

local function drawExplorer(workspace, rect)
    graphics.imguiSetNextWindowPos(rect.x, rect.y)
    graphics.imguiSetNextWindowSize(rect.w, rect.h)

    graphics.imguiBegin("Explorer", {"NoMove"})

    drawNode(workspace)

    graphics.imguiEnd()
end

return {
    drawExplorer = drawExplorer,
    getSelected = function()
        return SelectionService.current
    end
}