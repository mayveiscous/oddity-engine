local graphics = require "oddity.graphics"

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

        Dock = {
            x = 0,
            y = topOffset,
            w = winW,
            h = winH - topOffset,
        },

        PanelWidth = panelWidth,
        OutputHeight = outputHeight,
        ExplorerHeightRatio = explorerHeightRatio,
    }
end

return Layout