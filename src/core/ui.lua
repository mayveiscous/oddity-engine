local graphics = require "graphics"

local ui = {}

function ui.beginWindow(title, flags)
graphics.imguiBegin(title, flags)
end

function ui.endWindow()
graphics.imguiEnd()
end

function ui.beginChild(id, width, height, border)
return graphics.imguiBeginChild(id, width, height, border)
end

function ui.endChild()
graphics.imguiEndChild()
end

function ui.text(text)
graphics.imguiText(text)
end

function ui.textColored(r, g, b, a, text)
graphics.imguiTextColored(r, g, b, a, text)
end

function ui.separator()
graphics.imguiSeparator()
end

function ui.vector2(label, x, y)
    return graphics.imguiVector2(label, x, y)
end

function ui.textDisabled(text)
    graphics.imguiTextDisabled(text)
end

function ui.spacing()
graphics.imguiSpacing()
end

function ui.newLine()
graphics.imguiNewLine()
end

function ui.sameLine(offset, spacing)
graphics.imguiSameLine(offset, spacing)
end

function ui.button(text, width, height)
return graphics.imguiButton(text, width, height)
end

function ui.smallButton(text)
return graphics.imguiSmallButton(text)
end

function ui.buttonEx(text, selected, width, height)
return graphics.imguiButtonEx(text, selected, width, height)
end

function ui.selectable(label)
return graphics.imguiSelectable(label)
end

function ui.inputText(label, initial)
local value, changed = graphics.imguiInputText(label, initial)
return value, changed
end

function ui.inputTextMultiline(label, text, maxLength)
return graphics.imguiInputTextMultiline(label, text, maxLength)
end

function ui.inputInt(label, value)
return graphics.imguiInputInt(label, value)
end

function ui.inputFloat(label, value)
return graphics.imguiInputFloat(label, value)
end

function ui.vector3(label, x, y, z)
return graphics.imguiVector3(label, x, y, z)
end

function ui.color(label, r, g, b)
return graphics.imguiColor(label, r, g, b)
end

function ui.checkbox(label, value)
return graphics.imguiCheckbox(label, value)
end

function ui.sliderFloat(label, value, min, max)
return graphics.imguiSliderFloat(label, value, min, max)
end

function ui.combo(label, current, items)
return graphics.imguiCombo(label, current, items)
end

function ui.collapsingHeader(label, defaultOpen)
return graphics.imguiCollapsingHeader(label, defaultOpen)
end

function ui.treeNode(label, selected)
return graphics.imguiTreeNode(label, selected)
end

function ui.treeNodeEx(label, selected, forceOpen, isLeaf)
return graphics.imguiTreeNodeEx(label, selected, forceOpen, isLeaf)
end

function ui.openPopup(id)
    graphics.imguiOpenPopup(id)
end

function ui.beginPopup(id)
    return graphics.imguiBeginPopup(id)
end

function ui.endPopup()
    graphics.imguiEndPopup()
end

function ui.closeCurrentPopup()
    graphics.imguiCloseCurrentPopup()
end

function ui.treePop()
graphics.imguiTreePop()
end

function ui.beginTabBar(id)
return graphics.imguiBeginTabBar(id)
end

function ui.endTabBar()
graphics.imguiEndTabBar()
end

function ui.beginTabItem(label)
return graphics.imguiBeginTabItem(label)
end

function ui.endTabItem()
graphics.imguiEndTabItem()
end

function ui.image(texture, width, height)
graphics.imguiImage(texture, width, height)
end

function ui.dummy(width, height)
graphics.imguiDummy(width, height)
end

function ui.setCursorPosX(x)
graphics.imguiSetCursorPosX(x)
end

function ui.beginGroup()
graphics.imguiBeginGroup()
end

function ui.endGroup()
graphics.imguiEndGroup()
end

function ui.setNextWindowPos(x, y)
graphics.imguiSetNextWindowPos(x, y)
end

function ui.setNextWindowSize(width, height)
graphics.imguiSetNextWindowSize(width, height)
end

function ui.windowCollapsed(id)
return graphics.imguiWindowCollapsed(id)
end

function ui.setStyle(style)
graphics.imguiSetStyle(style)
end

function ui.setColor(name, r, g, b, a)
graphics.imguiSetColor(name, r, g, b, a)
end

function ui.pushStyleColor(name, r, g, b, a)
graphics.imguiPushStyleColor(name, r, g, b, a)
end

function ui.popStyleColor(count)
graphics.imguiPopStyleColor(count)
end

function ui.wantsMouse()
return graphics.imguiWantsMouse()
end

function ui.beginMainMenuBar()
return graphics.imguiBeginMainMenuBar()
end

function ui.endMainMenuBar()
graphics.imguiEndMainMenuBar()
end

function ui.beginMenu(label)
return graphics.imguiBeginMenu(label)
end

function ui.endMenu()
graphics.imguiEndMenu()
end

function ui.menuItem(label)
return graphics.imguiMenuItem(label)
end

return ui