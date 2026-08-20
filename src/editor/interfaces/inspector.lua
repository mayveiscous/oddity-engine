local Explorer = require "src.editor.interfaces.explorer"
local ui = require "src.core.ui"

local EditorState = require "src.editor.state"

local Vector3 = require "src.types.vector3"
local Vector2 = require "src.types.vector2"
local Color3 = require "src.types.color3"
local Enum = require "src.types.enum"

local LABEL_WIDTH = 110

local function isVector3(v)
    return type(v) == "table"
        and v._state
        and v._state._isVector3
end

local function isVector2(v)
    return type(v) == "table"
        and v._state
        and v._state._isVector2
end

local function isColor3(v)
    return type(v) == "table"
        and v._state
        and v._state._isColor3
end

local function isInstance(v)
    return type(v) == "table"
        and getmetatable(v)
        and v.ClassName ~= nil
end

local PROPERTY_OPTIONS = {
    Face = Enum.Faces,
    Material = Enum.MaterialNames,
    Shape = Enum.Shapes,
}

local function getPropertyOptions(name)
    return PROPERTY_OPTIONS[name]
end

local function drawPropertyLabel(name)
    ui.text(name)
    ui.sameLine()
    ui.setCursorPosX(LABEL_WIDTH)
end

local function drawPropertyRow(name, drawControl)
    drawPropertyLabel(name)
    return drawControl("##" .. name)
end

local function drawCombo(id, value, options)
    local current = 0

    for i, option in ipairs(options) do
        if option == value then
            current = i - 1
            break
        end
    end

    local newCurrent, changed = ui.combo(
        id,
        current,
        options
    )

    if changed then
        return options[newCurrent + 1], true
    end

    return value, false
end

local function drawPropertyControl(name, value)
    local options = getPropertyOptions(name)

    if options then
        return drawPropertyRow(name, function(id)
            return drawCombo(id, value, options)
        end)
    end

    if type(value) == "boolean" then
        return drawPropertyRow(name, function(id)
            return ui.checkbox(id, value)
        end)
    end

    if type(value) == "number" then
        return drawPropertyRow(name, function(id)
            return ui.inputFloat(id, value)
        end)
    end

    if type(value) == "string" then
        return drawPropertyRow(name, function(id)
            return ui.inputText(id, value)
        end)
    end

    if isVector3(value) then
        return drawPropertyRow(name, function(id)
            local x, y, z, changed = ui.vector3(
                id,
                value.X,
                value.Y,
                value.Z
            )

            if changed then
                return Vector3.new(x, y, z), true
            end

            return value, false
        end)
    end

    if isVector2(value) then
        return drawPropertyRow(name, function(id)
            local x, y, changed = ui.vector2(
                id,
                value.X,
                value.Y
            )

            if changed then
                return Vector2.new(x, y), true
            end

            return value, false
        end)
    end

    if isColor3(value) then
        return drawPropertyRow(name, function(id)
            local r, g, b, changed = ui.color(
                id,
                value.R,
                value.G,
                value.B
            )

            if changed then
                return Color3.new(r, g, b), true
            end

            return value, false
        end)
    end

    if isInstance(value) then
        drawPropertyLabel(name)
        ui.textDisabled(value.Name or value.ClassName)

        return value, false
    end

    drawPropertyLabel(name)
    ui.textDisabled(tostring(value))

    return value, false
end

local function sortedProperties(properties)
    local list = {}

    for name, definition in pairs(properties) do
        table.insert(list, {
            name = name,
            definition = definition,
            value = definition.value,
        })
    end

    table.sort(list, function(a, b)
        return a.name < b.name
    end)

    return list
end

local function sortedCategories(properties)
    local categories = {}

    for category in pairs(properties) do
        if category ~= "Hidden" then
            table.insert(categories, category)
        end
    end

    table.sort(categories)

    return categories
end

local function drawObjectHeader(inst)
    ui.text(inst.Name)

    ui.sameLine()
    ui.textDisabled("[" .. inst.ClassName .. "]")

    ui.separator()
end

local function drawInspector()
    ui.beginWindow("Properties")

    if ui.isWindowHovered() then
        EditorState.AttentionFocus = "Properties"
    end

    local inst = Explorer.getSelected()

    if not inst then
        ui.spacing()
        ui.textDisabled("Select an object to view its properties.")
        ui.endWindow()
        return
    end

    drawObjectHeader(inst)

    local props = inst:GetProperties()

    for _, category in ipairs(sortedCategories(props)) do
        local properties = props[category]

        if ui.collapsingHeader(category, true) then
            for _, property in ipairs(sortedProperties(properties)) do
                local definition = property.definition
                local oldValue = property.value

                local newValue, changed

                if definition.readOnly then
                    drawPropertyLabel(property.name)
                    ui.textDisabled(tostring(oldValue))
                else
                    newValue, changed = drawPropertyControl(
                        property.name,
                        oldValue
                    )
                end

                if changed and newValue ~= oldValue then
                    inst[property.name] = newValue
                end
            end
        end
    end

    ui.endWindow()
end

return {
    drawInspector = drawInspector
}