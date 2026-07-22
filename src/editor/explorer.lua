local SelectionService = require("src.classes.selectionservice")
local Layout = require("src.editor.layout")

local graphics = require("graphics")

local expanded = {}

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

local function drawNode(instance)
    local label = instance.Name .. " (" .. instance.ClassName .. ")"

    local selected = (SelectionService.current == instance)

    local forceOpen = shouldExpand(instance)

    local open, clicked = graphics.imguiTreeNodeEx(
        label,
        selected,
        forceOpen
    )

    if clicked then
        SelectionService.Select(instance)
    end

    if open then
        for _, child in ipairs(instance:GetChildren()) do
            drawNode(child)
        end

        graphics.imguiTreePop()
    end
end

local function drawExplorer(workspace)
    local rects = Layout.apply()
    graphics.imguiSetNextWindowPos(rects.Explorer.x, rects.Explorer.y)
    graphics.imguiSetNextWindowSize(rects.Explorer.w, rects.Explorer.h)
    graphics.imguiBegin("Explorer", {"NoMove", "NoResize", "NoCollapse"})
    drawNode(workspace)
    graphics.imguiEnd()
end

return {
    drawExplorer = drawExplorer,
    getSelected = function()
        return SelectionService.current
    end
}