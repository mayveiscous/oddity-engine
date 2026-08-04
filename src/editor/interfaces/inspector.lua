local Explorer = require "src.editor.interfaces.explorer"
local Layout = require "src.editor.state.layout"
local graphics = require "graphics"

local Vector3 = require "src.types.vector3"
local Vector2 = require "src.types.vector2"
local Color3 = require "src.types.color3"

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
        local newValue, changed = graphics.imguiCheckbox(name, value)

        if changed then
            return newValue
        end
    elseif type(value) == "number" then
        local newValue, changed = graphics.imguiInputFloat(name, value)

        if changed then
            return newValue
        end
    elseif isVector3(value) then
        local x, y, z, changed = graphics.imguiVector3(
            name,
            value.X,
            value.Y,
            value.Z
        )

        if changed then
            return Vector3.new(x, y, z)
        end
    elseif isColor3(value) then
        local r, g, b, changed = graphics.imguiColor(
            name,
            value.R,
            value.G,
            value.B
        )

        if changed then
            return Color3.new(r, g, b)
        end
    elseif isVector2(value) then
        -- expose a vector2 thing in imgui?
    else
        graphics.imguiText(name .. ": " .. tostring(value))
    end

    return value
end

local function drawInspector(rects)
    graphics.imguiSetNextWindowPos(rects.x, rects.y)
    graphics.imguiSetNextWindowSize(rects.w, rects.h)
    graphics.imguiBegin("Properties", {"NoMove"})

    local inst = Explorer.getSelected()

    if inst then
        local props = inst:GetProperties()

        for category, properties in pairs(props) do 
            if graphics.imguiCollapsingHeader(category, true) then
                for name, value in pairs(properties) do
                    local newValue = drawProperty(name, value)

                    if newValue ~= value then
                        inst[name] = newValue
                    end
                end
            end
        end
    end

    graphics.imguiEnd()
end

return {drawInspector = drawInspector}