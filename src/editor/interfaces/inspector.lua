local Explorer = require "src.editor.interfaces.explorer"
local ui = require "src.core.ui"

local Vector3 = require "src.types.vector3"
local Vector2 = require "src.types.vector2"
local Color3 = require "src.types.color3"

local LABEL_WIDTH = 100

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

local function drawLabel(name)
    ui.text(name)
    ui.sameLine()
    ui.setCursorPosX(LABEL_WIDTH)
end

local function drawProperty(name, value, readOnly)
    drawLabel(name)

    if readOnly then
        ui.textDisabled(tostring(value))
        return value
    end

    if type(value) == "boolean" then
        local newValue, changed =
            ui.checkbox("##" .. name, value)

        if changed then
            return newValue
        end

    elseif type(value) == "number" then
        local newValue, changed =
            ui.inputFloat("##" .. name, value)

        if changed then
            return newValue
        end

    elseif type(value) == "string" then
        local newValue, changed = ui.inputText("##" .. name, value)

        if changed then
            return newValue
        end

    elseif isVector3(value) then
        local x, y, z, changed = ui.vector3(
            "##" .. name,
            value.X,
            value.Y,
            value.Z
        )

        if changed then
            return Vector3.new(x, y, z)
        end

    elseif isVector2(value) then
        local x, y, changed = ui.vector2(
            "##" .. name,
            value.X,
            value.Y
        )

        if changed then
            return Vector2.new(x, y)
        end

    elseif isColor3(value) then
        local r, g, b, changed = ui.color(
            "##" .. name,
            value.R,
            value.G,
            value.B
        )

        if changed then
            return Color3.new(r, g, b)
        end

    elseif isInstance(value) then
        ui.text(value.Name or value.ClassName)

    else
        ui.text(tostring(value))
    end

    return value
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

local function drawInspector(rects)
    ui.setNextWindowPos(rects.x, rects.y)
    ui.setNextWindowSize(rects.w, rects.h)

    ui.beginWindow("Properties", {"NoMove"})

    local inst = Explorer.getSelected()

    if not inst then
        ui.textDisabled("No object selected")
        ui.endWindow()
        return
    end

    ui.text(inst.Name)
    ui.textDisabled(inst.ClassName)

    ui.separator()

    local props = inst:GetProperties()

    for category, properties in pairs(props) do
        if category ~= "Hidden" then
            if ui.collapsingHeader(category, true) then
                for _, property in ipairs(sortedProperties(properties)) do
                    local oldValue = property.value
                    local newValue = drawProperty(property.name, oldValue, property.definition.readOnly)

                    if not property.definition.readOnly
                        and newValue ~= oldValue then

                        inst[property.name] = newValue
                    end
                end
            end
        end
    end

    ui.endWindow()
end

return {
    drawInspector = drawInspector
}