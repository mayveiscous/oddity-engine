local render = require("render")

local selectedInstance = nil

local function drawNode(instance)
    local label = instance.Name .. " (" .. instance.ClassName .. ")"

    local open, clicked = render.imguiTreeNodeEx(label)

    if clicked then
        selectedInstance = instance
    end

    if open then
        for _, child in ipairs(instance:GetChildren()) do
            drawNode(child)
        end
        render.imguiTreePop()
    end
end

local function drawExplorer(workspace)
    render.imguiBegin("Explorer")
    drawNode(workspace)
    render.imguiEnd()
end

return {
    drawExplorer = drawExplorer,
    getSelected = function()
        return selectedInstance
    end
}