local render = require("render")

local Layout = {}

function Layout.begin()

    local screenW = render.getWidth()
    local screenH = render.getHeight()

    local topBarHeight = 30

    local rightWidth = 320
    local bottomHeight = 230

    ---------------------------------------------------
    -- Explorer
    ---------------------------------------------------

    render.imguiSetNextWindowPos(
        screenW - rightWidth,
        topBarHeight
    )

    render.imguiSetNextWindowSize(
        rightWidth,
        screenH * 0.45
    )

    ---------------------------------------------------
    -- Properties
    ---------------------------------------------------

    render.imguiSetNextWindowPos(
        screenW - rightWidth,
        topBarHeight + screenH * 0.45
    )

    render.imguiSetNextWindowSize(
        rightWidth,
        screenH * 0.55 - bottomHeight
    )

end

function Layout.finish()

end

return Layout