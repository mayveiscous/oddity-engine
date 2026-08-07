local EditorState = require "src.editor.state"
local Tabs = require "src.editor.state.tabs"
local ui = require "src.core.ui"

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

        if ui.button((selected and "[ " or "") .. tab.name .. (selected and " ]" or "")) then
            Tabs.setActiveIndex(i)
        end

        ui.sameLine()
    end

    ui.newLine()
end

local function drawContent()
    local tab = Tabs.getActive()

    if not tab then
        return
    end

    if tab.type == "scene" then
        ui.text("Scene Editor")
        return
    end

    if tab.type == "script" then
        local content = Tabs.getScriptContent(tab.script)
        local changed, newText = ui.inputTextMultiline("##editor", content, 10000)

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

    ui.setNextWindowPos(tabRect.x, tabRect.y)
    ui.setNextWindowSize(tabRect.w, tabRect.h)

    ui.beginWindow("Document Tabs", {"NoTitleBar", "NoScrollBar", "NoMove"})

    drawTabs()

    ui.endWindow()

    local tab = Tabs.getActive()

    if not tab then
        return
    end

    if tab.type == "scene" then
        return
    end

    local editorRect = rects.TextEditor

    ui.setNextWindowPos(editorRect.x, editorRect.y)
    ui.setNextWindowSize(editorRect.w, editorRect.h)

    ui.beginWindow("Text Editor")

    drawContent()

    ui.endWindow()
end

return TextEditor