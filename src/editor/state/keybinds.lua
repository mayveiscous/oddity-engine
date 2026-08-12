local Signal = require "oddity.signal"
local InputService = require "src.classes.services.inputservice"

local KBM = {}

-- combinations
KBM.DuplicatePressed = Signal.new()
KBM.UndoPressed = Signal.new()
KBM.RedoPressed = Signal.new()
KBM.CopyPressed = Signal.new()
KBM.PastePressed = Signal.new()

-- singles
KBM.ToolChange = Signal.new()
KBM.Delete = Signal.new()

-- camera controller specific
KBM.Wasd = Signal.new()

local wasdLastState = {
    W = false,
    A = false,
    S = false,
    D = false,
}

function KBM.poll()
    local leftCDown = InputService.IsKeyDown("LeftControl")

    if leftCDown and InputService.IsKeyPressed("D") then
        KBM.DuplicatePressed:Fire()
    elseif leftCDown and InputService.IsKeyPressed("Z") then
        KBM.UndoPressed:Fire()
    elseif leftCDown and InputService.IsKeyPressed("Y") then
        KBM.RedoPressed:Fire()
    elseif leftCDown and InputService.IsKeyPressed("C") then
        KBM.CopyPressed:Fire()
    elseif leftCDown and InputService.IsKeyPressed("V") then
        KBM.PastePressed:Fire()
    end

    if InputService.IsKeyPressed("Backspace") then
        KBM.Delete:Fire()
    end

    local controlDown = InputService.IsKeyDown("LeftControl") or InputService.IsKeyDown("RightControl")

    if not controlDown then
        for _, key in ipairs({"W", "A", "S", "D"}) do
            local isDown = InputService.IsKeyDown(key)

            if isDown ~= wasdLastState[key] then
                KBM.Wasd:Fire(key, isDown)
                wasdLastState[key] = isDown
            end
        end
    end

    if InputService.IsKeyPressed("One") then
        KBM.ToolChange:Fire("Select")
    elseif InputService.IsKeyPressed("Two") then
        KBM.ToolChange:Fire("Move")
    elseif InputService.IsKeyPressed("Three") then
        KBM.ToolChange:Fire("Scale")
    elseif InputService.IsKeyPressed("Four") then
        KBM.ToolChange:Fire("Rotate")
    end
end

return KBM