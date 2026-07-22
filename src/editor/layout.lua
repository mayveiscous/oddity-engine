local render = require("render")

local Layout = {}

local explorerHeightRatio = 0.55
local panelWidth = 300

function Layout.apply()
    local winW, winH = render.getWindowSize()

    local rects = {
        Explorer = {
            x = winW - panelWidth, y = 0,
            w = panelWidth, h = winH * explorerHeightRatio,
        },
        Inspector = {
            x = winW - panelWidth, y = winH * explorerHeightRatio,
            w = panelWidth, h = winH * (1 - explorerHeightRatio),
        },
    }

    return rects
end

return Layout