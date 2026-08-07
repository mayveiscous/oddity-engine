local graphics = require "graphics"
local EditorState = require "src.editor.state"
local Tabs = require "src.editor.state.tabs"

local TextEditor = {}

function TextEditor.openScript(script)
    Tabs.openScript(script)
end

function TextEditor.closeScript(script)
    Tabs.closeScript(script)
end

function TextEditor.updateScript(script)
    Tabs.updateScript(script)
end

function TextEditor.discardPendingEdits()
    Tabs.discardPendingEdits()
end

local function drawTabs()
    for i, tab in ipairs(Tabs.list()) do
        local selected = i == Tabs.getActiveIndex()

        if graphics.imguiButton((selected and "[ " or "") .. tab.name .. (selected and " ]" or "")) then
            Tabs.setActiveIndex(i)
        end

        graphics.imguiSameLine()
    end

    graphics.imguiNewLine()
end

local function drawContent()
    local tab = Tabs.getActive()

    if not tab then
        return
    end

    if tab.type == "scene" then
        graphics.imguiText("Scene Editor")
        return
    end

    if tab.type == "script" then
        local content = Tabs.getScriptContent(tab.script)
        local changed, newText = graphics.imguiInputTextMultiline("##editor", content, 10000)

        if changed then
            Tabs.setScriptContent(tab.script, newText)

            if not EditorState.isPlaytesting then
                tab.script.Source = newText
            end
        end
    end
end

function TextEditor.draw(rects)
    local tabRect = rects.DocumentTabs

    graphics.imguiSetNextWindowPos(tabRect.x, tabRect.y)
    graphics.imguiSetNextWindowSize(tabRect.w, tabRect.h)

    graphics.imguiBegin("Document Tabs", {"NoTitleBar", "NoScrollBar", "NoMove"})

    drawTabs()

    graphics.imguiEnd()

    local tab = Tabs.getActive()

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