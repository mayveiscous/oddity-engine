local graphics = require("graphics")

local Layout = {}

local explorerHeightRatio = 0.55
local panelWidth = 300
local outputHeight = 250
local topBarHeight = 100
local collapsedMargin = 20

function Layout.apply(collapsed)
    local winW, winH = graphics.getWindowSize()

    local topOffset = collapsed.TopBar and collapsedMargin or topBarHeight

    local editorHeight = winH - topOffset
    local editorWidth = winW - panelWidth

    local explorerHeight
    local inspectorHeight

    if collapsed.Explorer then
        explorerHeight = collapsedMargin
    else
        explorerHeight = editorHeight * explorerHeightRatio
    end

    inspectorHeight = editorHeight - explorerHeight

    return {
        TopBar = {
            x = 0,
            y = 0,
            w = winW,
            h = topBarHeight,
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