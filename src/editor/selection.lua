local Game = require("src.game")
local RunService = require("src.classes.runservice")
local InputService = require("src.classes.inputservice")
local SelectionService = require("src.classes.selectionservice")
local render = require("render")

RunService.Heartbeat:Connect(function(dt)
    if not render.imguiWantsMouse() and InputService.IsMouseButtonDown("One") then
        local x, y = InputService.GetMousePos()
        local hit = render.raycast(x, y)

        if hit then
            local inst = Game.Workspace:FindByUniqueId(hit)
            if inst then
                if inst.Locked then
                    SelectionService.Clear()
                    return
                end
                SelectionService.Select(inst)
            end
        else
            SelectionService.Clear()
        end
    end
end)