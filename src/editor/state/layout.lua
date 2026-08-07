local graphics = require "graphics"

local Layout = {}

local explorerHeightRatio = 0.55
local panelWidth = 300
local outputHeight = 225
local topBarHeight = 100
local documentBarHeight = 35
local collapsedMargin = 20

function Layout.apply(collapsed)
    local winW, winH = graphics.getWindowSize()

    local topOffset = collapsed.TopBar and collapsedMargin or topBarHeight

    local editorStartY = topOffset + documentBarHeight

    local editorWidth = winW - panelWidth
    local leftHeight = winH - editorStartY

    local panelHeight = winH - topOffset

    local explorerHeight

    if collapsed.Explorer then
        explorerHeight = collapsedMargin
    else
        explorerHeight = panelHeight * explorerHeightRatio
    end

    local inspectorHeight = panelHeight - explorerHeight

    return {
        TopBar = {
            x = 0,
            y = 0,
            w = winW,
            h = topBarHeight,
        },

        DocumentTabs = {
            x = 0,
            y = topOffset,
            w = editorWidth,
            h = documentBarHeight,
        },

        TextEditor = {
            x = 0,
            y = editorStartY,
            w = editorWidth,
            h = leftHeight - outputHeight,
        },

        Explorer = {
            x = winW - panelWidth,
            y = topOffset,
            w = panelWidth,
            h = explorerHeight,
        },

        Inspector = {
            x = winW - panelWidth,
            y = topOffset + explorerHeight,
            w = panelWidth,
            h = inspectorHeight,
        },

        Output = {
            x = 0,
            y = winH - outputHeight,
            w = editorWidth,
            h = outputHeight,
        },
    }
end

return Layout