local graphics = require("graphics")

local Theme = {}

local palette = {
    bg          = {0.098, 0.106, 0.129, 1.00},
    bgDark      = {0.071, 0.078, 0.094, 1.00},
    bgLight     = {0.145, 0.157, 0.184, 1.00},

    border      = {0.220, 0.235, 0.267, 0.60},

    text        = {0.906, 0.914, 0.925, 1.00},
    textDim     = {0.557, 0.576, 0.612, 1.00},

    accent      = {0.302, 0.541, 0.973, 1.00},
    accentHover = {0.400, 0.620, 1.000, 1.00},
    accentActive= {0.220, 0.451, 0.878, 1.00},

    header      = {0.180, 0.196, 0.235, 1.00},
    headerHover = {0.243, 0.267, 0.318, 1.00},
    headerActive= {0.302, 0.541, 0.973, 0.80},
}

local styleVars = {
    WindowPadding    = {10, 10},
    FramePadding     = {8, 4},
    ItemSpacing      = {8, 6},
    ItemInnerSpacing = {6, 4},
    IndentSpacing    = 18,

    WindowRounding   = 6,
    ChildRounding    = 4,
    FrameRounding    = 4,
    PopupRounding    = 4,
    ScrollbarRounding= 6,
    GrabRounding     = 4,
    TabRounding      = 4,

    WindowBorderSize = 1,
    FrameBorderSize  = 0,
    PopupBorderSize  = 1,

    ScrollbarSize    = 14,
    GrabMinSize      = 10,
}

local colors = {
    Text                  = palette.text,
    TextDisabled          = palette.textDim,

    WindowBg              = palette.bg,
    ChildBg               = palette.bg,
    PopupBg               = palette.bgDark,

    Border                = palette.border,
    BorderShadow          = {0, 0, 0, 0},

    FrameBg               = palette.bgLight,
    FrameBgHovered         = palette.headerHover,
    FrameBgActive          = palette.headerActive,

    TitleBg               = palette.bgDark,
    TitleBgActive          = palette.bgDark,
    TitleBgCollapsed       = palette.bgDark,

    MenuBarBg             = palette.bgDark,

    ScrollbarBg            = palette.bgDark,
    ScrollbarGrab          = palette.bgLight,
    ScrollbarGrabHovered   = palette.headerHover,
    ScrollbarGrabActive    = palette.accent,

    CheckMark              = palette.accent,

    SliderGrab              = palette.accent,
    SliderGrabActive        = palette.accentActive,

    Button                  = palette.header,
    ButtonHovered           = palette.headerHover,
    ButtonActive            = palette.accentActive,

    Header                  = palette.header,
    HeaderHovered           = palette.headerHover,
    HeaderActive            = palette.headerActive,

    Separator               = palette.border,
    SeparatorHovered        = palette.accent,
    SeparatorActive         = palette.accent,

    Tab                     = palette.bgDark,
    TabHovered              = palette.headerHover,
    TabActive               = palette.header,
    TabUnfocused            = palette.bgDark,
    TabUnfocusedActive      = palette.header,
}

function Theme.apply()
    graphics.imguiSetStyle(styleVars)
 
    for name, c in pairs(colors) do
        local ok, err = pcall(graphics.imguiSetColor, name, c[1], c[2], c[3], c[4])
        if not ok then
            if not tostring(err):find("Unknown ImGui color") then
                error(err)
            end
        end
    end
end

Theme.palette = palette

return Theme