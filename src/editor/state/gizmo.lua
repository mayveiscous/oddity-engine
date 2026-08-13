local SelectionService = require "src.classes.services.selectionservice"
local PhysicsEngine = require "src.physics.core.engine"

local Game = require "src.game"
local Vector3 = require "src.types.vector3"

local graphics = require "oddity.graphics"
local ui = require "src.core.ui"

local Math = require "src.editor.state.gizmo.math"
local Snap = require "src.editor.state.gizmo.snap"

local Gizmo = {}

Gizmo.dragging = nil
Gizmo.freeDragging = false

local CONFIG = {
    axisLength = 2,
    axisGap = 1,
    axisThickness = 0.75,

    snapThreshold = 0.35,
    snapReleaseThreshold = 1,
    snapEnabled = true,

    cameraScale = 0.1,
    minScale = 0.5,
    maxScale = 8,

    hoverScale = 1.12,
    activeScale = 1.18,
}

local AXES = {
    {
        key = "X",
        id = "gizmo_move_x",
        direction = Vector3.new(1, 0, 0),
        color = {1, 0.2, 0.2},
    },

    {
        key = "Y",
        id = "gizmo_move_y",
        direction = Vector3.new(0, 1, 0),
        color = {0.2, 1, 0.2},
    },

    {
        key = "Z",
        id = "gizmo_move_z",
        direction = Vector3.new(0, 0, 1),
        color = {0.2, 0.4, 1},
    },
}

local state = {
    hoveredAxis = nil,

    drag = {
        active = false,
        mode = nil,

        axis = nil,
        instance = nil,

        startPosition = nil,

        planeNormal = nil,
        startHit = nil,
        startAxisPosition = nil,

        contactNormal = nil,
        contactInstance = nil,

        snapTargets = Snap.newState(),
        snapObjects = nil,
    },
}

local function getSelected()
    local inst = SelectionService.current

    if not inst or not inst.Position or not inst.Size then
        return nil
    end

    return inst
end

local function getAxisById(id)
    for _, axis in ipairs(AXES) do
        if axis.id == id then
            return axis
        end
    end

    return nil
end

local function getSnapObjects(inst)
    local objects = {}

    for _, obj in ipairs(Game.Workspace:GetDescendants()) do
        if obj ~= inst and obj.Position and obj.Size then
            objects[#objects + 1] = obj
        end
    end

    return objects
end

local function clearDragState()
    local drag = state.drag

    drag.active = false
    drag.mode = nil
    drag.axis = nil
    drag.instance = nil

    drag.startPosition = nil
    drag.planeNormal = nil
    drag.startHit = nil
    drag.startAxisPosition = nil
    drag.snapObjects = nil

    drag.contactNormal = nil
    drag.contactInstance = nil

    drag.dragRight = nil
    drag.dragUp = nil

    Snap.clear(drag.snapTargets)

    Gizmo.dragging = nil
    Gizmo.freeDragging = false
end

local CONTACT_DIRECTIONS = {
    Vector3.new(1, 0, 0),
    Vector3.new(-1, 0, 0),
    Vector3.new(0, 1, 0),
    Vector3.new(0, -1, 0),
    Vector3.new(0, 0, 1),
    Vector3.new(0, 0, -1),
}

local function findContact(inst)
    local workspace = Game.Workspace
    local bestHit = nil

    local halfSize = Vector3.new(inst.Size.X / 2, inst.Size.Y / 2, inst.Size.Z / 2)

    for _, direction in ipairs(CONTACT_DIRECTIONS) do
        local origin = inst.Position + Vector3.new(direction.X * halfSize.X, direction.Y * halfSize.Y, direction.Z * halfSize.Z)
        local hit = workspace:Raycast(origin, direction)

        if hit and hit.Instance ~= inst then
            if not bestHit or hit.Distance < bestHit.Distance then
                bestHit = hit
            end
        end
    end

    return bestHit
end

local function setObjectPosition(inst, position)
    inst.Position = position

    local physObj = PhysicsEngine.GetObjectForInstance(inst)

    if not physObj then
        return
    end

    physObj.m_position = position
    physObj.m_velocity = Vector3.new(0, 0, 0)

    if physObj.collider.Type == "AABB" then
        physObj.collider:Recenter(position)
    elseif physObj.collider.m_center then
        physObj.collider.m_center = position
    end
end

local function applySnap(inst, axis, position)
    local drag = state.drag

    if not CONFIG.snapEnabled then
        drag.snapTargets[axis.key] = nil
        return position
    end

    return Snap.apply(inst, axis, position, drag.snapTargets, drag.snapObjects or {}, CONFIG.snapThreshold, CONFIG.snapReleaseThreshold)
end

function Gizmo.setHoveredAxis(hitId)
    state.hoveredAxis = getAxisById(hitId)
end

function Gizmo.clearHoveredAxis()
    state.hoveredAxis = nil
end

function Gizmo.getHoveredAxis()
    return state.hoveredAxis
end

local function getGizmoScale(inst, cameraPosition)
    if not cameraPosition then
        return 1
    end

    local distance = Math.length(cameraPosition - inst.Position)
    local scale = distance * CONFIG.cameraScale

    return math.max(CONFIG.minScale, math.min(CONFIG.maxScale, scale))
end

local function getAxisColor(axis)
    local color = axis.color
    local scale = 1

    if state.hoveredAxis == axis then
        scale = 1.15
    end

    if state.drag.axis == axis then
        scale = 1.35
    end

    return {
        math.min(color[1] * scale, 1),
        math.min(color[2] * scale, 1),
        math.min(color[3] * scale, 1),
    }
end

local function getAxisVisualScale(axis)
    local scale = 1

    if state.hoveredAxis == axis then
        scale = scale * CONFIG.hoverScale
    end

    if state.drag.axis == axis then
        scale = scale * CONFIG.activeScale
    end

    return scale
end

function Gizmo.draw(blockMeshId, cameraPosition)
    local inst = getSelected()

    if not inst then
        return
    end

    local scale = getGizmoScale(inst, cameraPosition)

    local axisLength = CONFIG.axisLength * scale
    local axisGap = CONFIG.axisGap * scale
    local axisThickness = CONFIG.axisThickness * scale

    for _, axis in ipairs(AXES) do
        local halfSize = Math.getAxisHalfSize(inst.Size, axis)
        local offset = halfSize + axisGap + axisLength / 2
        local center = inst.Position + axis.direction * offset

        local sx = axisThickness
        local sy = axisThickness
        local sz = axisThickness

        if axis.direction.X ~= 0 then
            sx = axisLength
        elseif axis.direction.Y ~= 0 then
            sy = axisLength
        else
            sz = axisLength
        end

        local visualScale = getAxisVisualScale(axis)

        sx = sx * visualScale
        sy = sy * visualScale
        sz = sz * visualScale

        local color = getAxisColor(axis)

        graphics.drawMesh(blockMeshId, center.X, center.Y, center.Z, sx, sy, sz, color[1], color[2], color[3], 0, 0, 0, 1, axis.id, nil)
    end
end

function Gizmo.tryBeginDrag(hitId, mx, my)
    if ui.wantCaptureMouse() then
        return false
    end

    local inst = getSelected()
    local axis = getAxisById(hitId)

    if not inst or not axis then
        return false
    end

    clearDragState()

    local rayOrigin, rayDirection = Math.getMouseRay(mx, my, graphics)
    local planeNormal = Math.getAxisDragPlane(axis, rayDirection)
    local startAxisPosition = Math.getAxisPosition(axis, mx, my, inst.Position, planeNormal, graphics)

    if not startAxisPosition then
        return false
    end

    local drag = state.drag

    drag.active = true
    drag.mode = "axis"

    drag.axis = axis
    drag.instance = inst

    drag.startPosition = inst.Position
    drag.planeNormal = planeNormal
    drag.startAxisPosition = startAxisPosition
    drag.snapObjects = getSnapObjects(inst)

    Gizmo.dragging = axis
    Gizmo.freeDragging = false

    return true
end

local function updateAxisDrag(mx, my)
    local drag = state.drag
    local inst = drag.instance
    local axis = drag.axis

    if not inst or not axis then
        return
    end

    local currentAxisPosition = Math.getAxisPosition(axis, mx, my, drag.startPosition, drag.planeNormal, graphics)

    if not currentAxisPosition then
        return
    end

    local delta = currentAxisPosition - drag.startAxisPosition
    local position = drag.startPosition + axis.direction * delta

    position = applySnap(inst, axis, position)

    setObjectPosition(inst, position)
end

function Gizmo.tryBeginFreeDrag(mx, my)
    if ui.wantCaptureMouse() then
        return false
    end

    local inst = getSelected()

    if not inst then
        return false
    end

    clearDragState()

    local rayOrigin, rayDirection = Math.getMouseRay(mx, my, graphics)
    local startHit = Math.rayPlaneIntersection(rayOrigin, rayDirection, inst.Position, rayDirection)

    if not startHit then
        return false
    end

    local snapObjects = getSnapObjects(inst)
    local contact = PhysicsEngine.GetContact(inst, snapObjects)

    local drag = state.drag

    drag.active = true
    drag.mode = "free"

    drag.instance = inst
    drag.startPosition = inst.Position

    drag.planeNormal = rayDirection
    drag.startHit = startHit
    drag.snapObjects = snapObjects

    if contact then
        drag.contactNormal = contact.Normal
        drag.contactInstance = contact.Instance
    end

    Gizmo.dragging = nil
    Gizmo.freeDragging = true

    return true
end

local function updateFreeDrag(mx, my)
    local drag = state.drag
    local inst = drag.instance

    if not inst or not drag.startHit then
        return
    end

    local rayOrigin, rayDirection = Math.getMouseRay(mx, my, graphics)
    local hit = Math.rayPlaneIntersection(rayOrigin, rayDirection, drag.startPosition, drag.planeNormal)

    if not hit then
        return
    end

    local delta = hit - drag.startHit
    local position = drag.startPosition + delta

    if CONFIG.snapEnabled then
        for _, axis in ipairs(AXES) do
            position = applySnap(inst, axis, position)
        end
    else
        Snap.clear(drag.snapTargets)
    end

    position = PhysicsEngine.ResolveDragPosition(inst, position, drag.snapObjects)

    setObjectPosition(inst, position)
end

function Gizmo.update(mx, my)
    if Gizmo.freeDragging then
        updateFreeDrag(mx, my)
    elseif Gizmo.dragging then
        updateAxisDrag(mx, my)
    end
end

function Gizmo.endDrag()
    clearDragState()
end

function Gizmo.endFreeDrag()
    clearDragState()
end

function Gizmo.updateDrag(mx, my)
    if Gizmo.dragging then
        updateAxisDrag(mx, my)
    end
end

function Gizmo.updateFreeDrag(mx, my)
    if Gizmo.freeDragging then
        updateFreeDrag(mx, my)
    end
end

function Gizmo.rayPlaneHit(rayOrigin, rayDirection, planePoint, planeNormal)
    return Math.rayPlaneIntersection(rayOrigin, rayDirection, planePoint, planeNormal)
end

function Gizmo.closestPointOnAxis(axis, mx, my)
    local drag = state.drag

    if not drag.active then
        return nil
    end

    return Math.getAxisPosition(axis, mx, my, drag.startPosition, drag.planeNormal, graphics)
end

function Gizmo.isDragging()
    return state.drag.active
end

function Gizmo.getDragMode()
    return state.drag.mode
end

function Gizmo.getDraggingAxis()
    return state.drag.axis
end

function Gizmo.isSnapping(axisKey)
    return state.drag.snapTargets[axisKey] ~= nil
end

function Gizmo.getSnapTarget(axisKey)
    return state.drag.snapTargets[axisKey]
end

function Gizmo.setSnapEnabled(enabled)
    CONFIG.snapEnabled = enabled

    if not enabled then
        Snap.clear(state.drag.snapTargets)
    end
end

function Gizmo.isSnapEnabled()
    return CONFIG.snapEnabled
end

return Gizmo