local Explorer = require("src.editor.explorer")
local Layout = require("src.editor.layout")
local render = require("render")

local Vector3 = require("src.types.vector3")
local Vector2 = require("src.types.vector2")
local Color3 = require("src.types.color3")

local function isVector3(v)
    return type(v) == "table" and v._state and v._state._isVector3
end

local function isVector2(v)
    return type(v) == "table" and v._state and v._state._isVector2
end

local function isColor3(v)
    return type(v) == "table" and v._state and v._state._isColor3
end

local function isInstance(v)
    return type(v) == "table" and getmetatable(v) and v.ClassName ~= nil
end

local function drawProperty(name, value)
    if type(value) == "boolean" then
        local newValue, changed = render.imguiCheckbox(name, value)

        if changed then
            return newValue
        end
    elseif type(value) == "number" then
        local newValue, changed = render.imguiInputFloat(name, value)

        if changed then
            return newValue
        end
    elseif isVector3(value) then
        local x, y, z, changed = render.imguiVector3(
            name,
            value.X,
            value.Y,
            value.Z
        )

        if changed then
            return Vector3.new(x, y, z)
        end
    elseif isColor3(value) then
        local r, g, b, changed = render.imguiColor(
            name,
            value.R,
            value.G,
            value.B
        )

        if changed then
            return Color3.new(r, g, b)
        end
    else
        render.imguiText(name .. ": " .. tostring(value))
    end

    return value
end

local function drawInspector()
    local inst = Explorer.getSelected()

    local rects = Layout.apply()
    render.imguiSetNextWindowPos(rects.Inspector.x, rects.Inspector.y)
    render.imguiSetNextWindowSize(rects.Inspector.w, rects.Inspector.h)
    render.imguiBegin("Properties")

    if inst then
        local props = inst:GetProperties()

        for category, properties in pairs(props) do
            if render.imguiCollapsingHeader(category, true) then
                for name, value in pairs(properties) do
                    local newValue = drawProperty(name, value)

                    if newValue ~= value then
                        inst[name] = newValue
                    end
                end
            end
        end
    end

    render.imguiEnd()
end

return {drawInspector = drawInspector}