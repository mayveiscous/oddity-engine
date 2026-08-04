local graphics = require "graphics"

local TextEditor = {}

local tabs = {
    {
        name = "Scene",
        type = "scene",
    }
}

local activeTab = 1

local scriptContents = {}

function TextEditor.openScript(path, content)
    for i, tab in ipairs(tabs) do
        if tab.path == path then
            activeTab = i
            return
        end
    end

    table.insert(tabs, {
        name = path:match("[^/]+$") or path,
        path = path,
        type = "script",
    })

    scriptContents[path] = content or ""

    activeTab = #tabs
end

function TextEditor.closeTab(index)
    if #tabs <= 1 then
        return
    end

    table.remove(tabs, index)

    if activeTab > #tabs then
        activeTab = #tabs
    elseif activeTab < 1 then
        activeTab = 1
    end
end

local function getActiveTab()
    if #tabs == 0 then
        return nil
    end

    if activeTab < 1 then
        activeTab = 1
    end

    if activeTab > #tabs then
        activeTab = #tabs
    end

    return tabs[activeTab]
end

local function drawTabs()
    for i, tab in ipairs(tabs) do
        local selected = i == activeTab

        if graphics.imguiButton((selected and "[ " or "") .. tab.name .. (selected and " ]" or "")) then
            activeTab = i
        end

        graphics.imguiSameLine()
    end

    graphics.imguiNewLine()
end

local function drawContent()
    local tab = getActiveTab()

    if not tab then
        return
    end

    if tab.type == "scene" then
        graphics.imguiText("Scene Editor")
        return
    end

    if tab.type == "script" then
        local content = scriptContents[tab.path] or ""

        local changed, newText = graphics.imguiInputTextMultiline("##editor", content, 10000)

        if changed then
            scriptContents[tab.path] = newText
        end
    end
end

function TextEditor.draw(rects)
    local tabRect = rects.DocumentTabs

    graphics.imguiSetNextWindowPos(tabRect.x, tabRect.y)
    graphics.imguiSetNextWindowSize(tabRect.w, tabRect.h)

    graphics.imguiBegin("Document Tabs")

    drawTabs()

    graphics.imguiEnd()

    local tab = getActiveTab()

    if not tab then
        return
    end

    if tab.type == "scene" then
        return
    end

    local editorRect = rects.TextEditor

    graphics.imguiSetNextWindowPos(editorRect.x, editorRect.y)
    graphics.imguiSetNextWindowSize(editorRect.w, editorRect.h)

    graphics.imguiBegin("Text Editor")

    drawContent()

    graphics.imguiEnd()
end

return TextEditor