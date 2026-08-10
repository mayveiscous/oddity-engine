local graphics = require "oddity.graphics"
local KeyCodes = require "src.data.keycodes"

local InputService = {}

local downThisFrame = {}
local downLastFrame = {}

function InputService.IsKeyDown(keyName)
    local code = KeyCodes.Keys[keyName]
    if not code then
        error(("Unknown key '%s"):format(keyName))
    end
    return graphics.isKeyDown(code)
end

function InputService.Update()
    downLastFrame = downThisFrame
    downThisFrame = {}
    for keyName in pairs(KeyCodes.Keys) do
        downThisFrame[keyName] = InputService.IsKeyDown(keyName)
    end
end

function InputService.IsKeyPressed(keyName)
    if not KeyCodes.Keys[keyName] then
        error(("Unknown key '%s"):format(keyName))
    end
    return downThisFrame[keyName] and not downLastFrame[keyName]
end

function InputService.GetMousePos()
    local x, y = graphics.getMousePos()
    return x, y
end

function InputService.IsMouseButtonDown(buttonName)
    local code = KeyCodes.MouseButtons[buttonName]
    if not code then
        error(("Unknown mouse button '%s'"):format(buttonName))
    end
    return graphics.isMouseButtonDown(code)
end

function InputService.GetMouseScroll()
    return graphics.getMouseScroll()
end

return InputService