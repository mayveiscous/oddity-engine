local Game = require("src.game")
local RunService = require("src.classes.runservice")
local InputService = require("src.classes.inputservice")
local SelectionService = require("src.classes.selectionservice")
local Gizmo = require("src.editor.gizmo")
local graphics = require("graphics")

RunService.Heartbeat:Connect(function(dt)
    if graphics.imguiWantsMouse() then
        return 
    end

    local x, y = InputService.GetMousePos()

    if InputService.IsMouseButtonDown("One") then
        if not Gizmo.dragging then
            local hit = graphics.raycast(x, y)

            if hit and Gizmo.tryBeginDrag(hit, x, y) then
                return
            end

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
        else
            Gizmo.updateDrag(x, y)
        end
    else
        Gizmo.endDrag()
    end
end)