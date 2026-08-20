local graphics = require "oddity.graphics"
local Enum = require "src.types.enum"

local KeyCodes = Enum.KeyCodes
local MouseButtons = Enum.MouseButtons

local InputService = {}

local downThisFrame = {}
local downLastFrame = {}

function InputService.IsKeyDown(keyName)
    local code = KeyCodes[keyName]
    if not code then
        error(("Unknown key '%s"):format(keyName), 2)
    end
    return graphics.isKeyDown(code)
end

function InputService.Update()
    downLastFrame = downThisFrame
    downThisFrame = {}
    for keyName in pairs(KeyCodes) do
        downThisFrame[keyName] = InputService.IsKeyDown(keyName)
    end
end

function InputService.IsKeyPressed(keyName)
    if not KeyCodes[keyName] then
        error(("Unknown key '%s"):format(keyName), 2)
    end
    return downThisFrame[keyName] and not downLastFrame[keyName]
end

function InputService.GetMousePos()
    local x, y = graphics.getMousePos()
    return x, y
end

function InputService.IsMouseButtonDown(buttonName)
    local code = MouseButtons[buttonName]
    if not code then
        error(("Unknown mouse button '%s'"):format(buttonName), 2)
    end
    return graphics.isMouseButtonDown(code)
end

function InputService.GetMouseScroll()
    return graphics.getMouseScroll()
end

return InputService