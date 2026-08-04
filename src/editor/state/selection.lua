local Game = require "src.game"
local RunService = require "src.classes.runservice"
local InputService = require "src.classes.inputservice"
local SelectionService = require "src.classes.selectionservice"
local EditorState = require "src.editor.state.layout"
local Gizmo = require "src.editor.state.gizmo"
local graphics = require "graphics"

local wasMouseDown = false

RunService.Heartbeat:Connect(function(dt)
    if EditorState.isPlaytesting then
        return 
    end
    
    if graphics.imguiWantsMouse() then
        wasMouseDown = false
        return 
    end

    local x, y = InputService.GetMousePos()
    local mouseDown = InputService.IsMouseButtonDown("One")

    if mouseDown then
        if Gizmo.dragging then
            Gizmo.updateDrag(x, y)
        elseif Gizmo.freeDragging then
            Gizmo.updateFreeDrag(x, y)
        elseif not wasMouseDown then
            local hit = graphics.raycast(x, y)

            if hit and Gizmo.tryBeginDrag(hit, x, y) then
                -- axis drag started
            elseif hit then
            local inst = Game.Workspace:FindByUniqueId(hit)
            if inst then
                if inst.Locked then
                    SelectionService.Clear()
                else
                    SelectionService.Select(inst)
                    Gizmo.tryBeginFreeDrag(x, y)
                end
            end
        else
                SelectionService.Clear()
            end
        end
    else
        Gizmo.endDrag()
        Gizmo.endFreeDrag()
    end

    wasMouseDown = mouseDown
end)