local render = require("render")
local KeyCodes = require("src.data.keycodes")

local InputService = {}

function InputService.IsKeyDown(keyName)
    local code = KeyCodes.Keys[keyName]
    if not code then
        error(("Unknown key '%s"):format(keyName))
    end
    return render.isKeyDown(code)
end

function InputService.GetMousePos()
    local x, y = render.getMousePos()
    return x, y
end

function InputService.IsMouseButtonDown(buttonName)
    local code = KeyCodes.MouseButtons[buttonName]
    if not code then
        error(("Unknown mouse button '%s'"):format(buttonName))
    end
    return render.isMouseButtonDown(code)
end

function InputService.GetMouseScroll()
    return render.getMouseScroll()
end

return InputService