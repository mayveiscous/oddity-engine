local ui = require "src.core.ui"

local Theme = {}

local palette = {
    bg = {0.090, 0.094, 0.106, 1.00},
    bgDark = {0.065, 0.068, 0.078, 1.00},
    bgLight = {0.125, 0.131, 0.145, 1.00},
    bgHover = {0.160, 0.168, 0.185, 1.00},

    border = {0.220, 0.228, 0.250, 0.75},

    text = {0.910, 0.914, 0.925, 1.00},
    textDim = {0.560, 0.575, 0.610, 1.00},
    textDisabled = {0.380, 0.390, 0.420, 1.00},

    accent = {0.345, 0.545, 0.900, 1.00},
    accentHover = {0.420, 0.620, 0.960, 1.00},
    accentActive = {0.275, 0.455, 0.800, 1.00},

    header = {0.135, 0.142, 0.158, 1.00},
    headerHover = {0.185, 0.195, 0.215, 1.00},
    headerActive = {0.345, 0.545, 0.900, 1.00},

    selection = {0.220, 0.365, 0.610, 0.65},
}

local styleVars = {
    WindowPadding = {10, 8},
    FramePadding = {7, 4},
    ItemSpacing = {7, 5},
    ItemInnerSpacing = {5, 4},
    IndentSpacing = 18,

    WindowRounding = 3,
    ChildRounding = 2,
    FrameRounding = 3,
    PopupRounding = 3,
    ScrollbarRounding = 3,
    GrabRounding = 3,
    TabRounding = 2,

    WindowBorderSize = 1,
    FrameBorderSize = 1,
    PopupBorderSize = 1,

    ScrollbarSize = 12,
    GrabMinSize = 10,
}

local colors = {
    Text = palette.text,
    TextDisabled = palette.textDisabled,

    WindowBg = palette.bg,
    ChildBg = palette.bg,
    PopupBg = palette.bgDark,

    Border = palette.border,
    BorderShadow = {0, 0, 0, 0},

    FrameBg = palette.bgLight,
    FrameBgHovered = palette.bgHover,
    FrameBgActive = palette.headerActive,

    TitleBg = palette.bgDark,
    TitleBgActive = palette.bgDark,
    TitleBgCollapsed = palette.bgDark,

    MenuBarBg = palette.bgDark,

    ScrollbarBg = palette.bgDark,
    ScrollbarGrab = palette.bgLight,
    ScrollbarGrabHovered = palette.bgHover,
    ScrollbarGrabActive = palette.accent,

    CheckMark = palette.accent,

    SliderGrab = palette.accent,
    SliderGrabActive = palette.accentHover,

    Button = palette.header,
    ButtonHovered = palette.headerHover,
    ButtonActive = palette.accentActive,

    Header = palette.header,
    HeaderHovered = palette.headerHover,
    HeaderActive = palette.headerActive,

    Separator = palette.border,
    SeparatorHovered = palette.accent,
    SeparatorActive = palette.accent,

    Tab = palette.bgDark,
    TabHovered = palette.headerHover,
    TabActive = palette.header,
    TabUnfocused = palette.bgDark,
    TabUnfocusedActive = palette.header,

    NavHighlight = palette.accent,
}

function Theme.apply()
    ui.setStyle(styleVars)

    for name, c in pairs(colors) do
        local ok, err = pcall(ui.setColor, name, c[1], c[2], c[3], c[4])

        if not ok then
            if not tostring(err):find("Unknown ImGui color") then
                error(err)
            end
        end
    end
end

Theme.palette = palette

return Theme