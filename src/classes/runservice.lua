local Signal = require("src.core.signal")
local task = require("task")

local RunService = {}

RunService.Heartbeat = Signal.new()

local running = false
local lastTime = nil

function RunService:Step()
    if not running then
        return
    end

    lastTime = lastTime or os.clock()
    local now = os.clock()
    local dt = now - lastTime

    task.update()
    RunService.Heartbeat:Fire(dt)

    lastTime = now
end

function RunService:Run()
    running = true
    lastTime = os.clock()

    while running do
        self:Step()
    end
end

function RunService:Stop()
    running = false
end

return RunService