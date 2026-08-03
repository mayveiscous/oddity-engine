local SelectionService = require "src.classes.selectionservice"
local Vector3 = require "src.types.vector3"

local Game = require "src.game"
local PhysicsEngine = require "src.physics.core.engine"

local graphics = require "graphics"

local Gizmo = {}
Gizmo.freeDragging = false

local freeDragStartObjPos = nil
local freeDragPlaneNormal = nil

local axisLength = 2
local axisGap = 1
local axisThickness = 0.75

local snapThreshold = 0.35
local snapReleaseThreshold = 1
local snapEnabled = true

local currentSnapTarget = nil

local axes = {
    { id = "gizmo_move_x", dir = Vector3.new(1, 0, 0), color = {1, 0.2, 0.2} },
    { id = "gizmo_move_y", dir = Vector3.new(0, 1, 0), color = {0.2, 1, 0.2} },
    { id = "gizmo_move_z", dir = Vector3.new(0, 0, 1), color = {0.2, 0.4, 1} },
}

local freeSnapTargets = { X = nil, Y = nil, Z = nil }

-- Keeps a live PhysicsObject (if the selected instance is one) in sync with
-- gizmo-driven position changes, so physics doesn't overwrite the edit next step.
local function syncPhysics(inst, pos)
    local physObj = PhysicsEngine.GetObjectForInstance(inst)
    if not physObj then return end

    physObj.m_position = pos
    physObj.m_velocity = Vector3.new(0, 0, 0)

    if physObj.collider.Type == "AABB" then
        physObj.collider:Recenter(pos)
    elseif physObj.collider.m_center then
        physObj.collider.m_center = pos
    end
end

local function axisKey(axis)
    if axis.dir.X ~= 0 then return "X"
    elseif axis.dir.Y ~= 0 then return "Y"
    else return "Z" end
end

local function dot(a, b)
    return a.X * b.X + a.Y * b.Y + a.Z * b.Z
end

local function normalize(v)
    local len = math.sqrt(v.X^2 + v.Y^2 + v.Z^2)
    if len == 0 then 
        return Vector3.new(0, 0, 0) 
    end

    return Vector3.new(
        v.X / len,
        v.Y / len,
        v.Z / len
    )
end

local function getFaces(pos, size, axis)
    local half
    if axis.dir.X ~= 0 then half = size.X / 2
    elseif axis.dir.Y ~= 0 then half = size.Y / 2
    else half = size.Z / 2 end

    local center = pos.X * axis.dir.X + pos.Y * axis.dir.Y + pos.Z * axis.dir.Z
    return center - half, center + half, center
end

local function findSnap(inst, axis, rawCenter)
    local half
    if axis.dir.X ~= 0 then half = inst.Size.X / 2
    elseif axis.dir.Y ~= 0 then half = inst.Size.Y / 2
    else half = inst.Size.Z / 2 end

    if currentSnapTarget then
        if math.abs(currentSnapTarget - rawCenter) < snapReleaseThreshold then
            return currentSnapTarget
        end
    end

    local best = nil
    local bestDelta = snapThreshold

    for _, obj in ipairs(Game.Workspace:GetDescendants()) do
        if obj ~= inst and obj.Position and obj.Size then
            local oMin, oMax, oCenter = getFaces(obj.Position, obj.Size, axis)
            local candidates = { oMax - half, oMin + half, oMin - half, oMax + half, oCenter }

            for _, cand in ipairs(candidates) do
                local delta = math.abs(cand - rawCenter)
                if delta < bestDelta then
                    bestDelta = delta
                    best = cand
                end
            end
        end
    end

    currentSnapTarget = best
    return best
end

local function findSnapFree(inst, axis, rawCenter)
    local half
    if axis.dir.X ~= 0 then half = inst.Size.X / 2
    elseif axis.dir.Y ~= 0 then half = inst.Size.Y / 2
    else half = inst.Size.Z / 2 end

    local key = axisKey(axis)
    local current = freeSnapTargets[key]

    if current and math.abs(current - rawCenter) < snapReleaseThreshold then
        return current
    end

    local best = nil
    local bestDelta = snapThreshold

    for _, obj in ipairs(Game.Workspace:GetDescendants()) do
        if obj ~= inst and obj.Position and obj.Size then
            local oMin, oMax, oCenter = getFaces(obj.Position, obj.Size, axis)
            local candidates = { oMax - half, oMin + half, oMin - half, oMax + half, oCenter }

            for _, cand in ipairs(candidates) do
                local delta = math.abs(cand - rawCenter)
                if delta < bestDelta then
                    bestDelta = delta
                    best = cand
                end
            end
        end
    end

    freeSnapTargets[key] = best
    return best
end

function Gizmo.closestPointOnAxis(axis, mx, my)
    local ox, oy, oz, dx, dy, dz = graphics.screenPointToRay(mx, my)

    local rayOrigin = Vector3.new(ox, oy, oz)
    local rayDir = Vector3.new(dx, dy, dz)
    local objectPos = SelectionService.current.Position
    local axisDir = axis.dir

    local w = rayOrigin - objectPos
    local a = dot(rayDir, rayDir)
    local b = dot(rayDir, axisDir)
    local c = dot(axisDir, axisDir)
    local d = dot(rayDir, w)
    local e = dot(axisDir, w)

    local denom = a * c - b * b
    if math.abs(denom) < 0.005 then
        return nil
    end

    return (a * e - b * d) / denom
end

function Gizmo.draw(blockMeshId)
    local inst = SelectionService.current
    if not inst or not inst.Position then return end

    for _, axis in ipairs(axes) do
        local halfSize = 0
        if axis.dir.X ~= 0 then halfSize = inst.Size.X / 2
        elseif axis.dir.Y ~= 0 then halfSize = inst.Size.Y / 2
        else halfSize = inst.Size.Z / 2 end

        local offset = halfSize + axisGap + (axisLength / 2)
        local center = inst.Position + axis.dir * offset

        local sx = (axis.dir.X ~= 0) and axisLength or axisThickness
        local sy = (axis.dir.Y ~= 0) and axisLength or axisThickness
        local sz = (axis.dir.Z ~= 0) and axisLength or axisThickness

        graphics.drawMesh(
            blockMeshId,
            center.X, center.Y, center.Z,
            sx, sy, sz,
            axis.color[1], axis.color[2], axis.color[3],
            0, 0, 0,
            1,
            axis.id
        )
    end
end

function Gizmo.tryBeginDrag(hitId, mx, my)
    for _, axis in ipairs(axes) do
        if axis.id == hitId then
            Gizmo.dragging = axis
            Gizmo.dragStartPos = SelectionService.current.Position
            Gizmo.dragStartOffset = Gizmo.closestPointOnAxis(axis, mx, my)
            return true
        end
    end
    return false
end

function Gizmo.updateDrag(mx, my)
    local axis = Gizmo.dragging
    local current = Gizmo.closestPointOnAxis(axis, mx, my)
    if current == nil then return end

    local inst = SelectionService.current
    local delta = current - Gizmo.dragStartOffset
    local rawPos = Gizmo.dragStartPos + axis.dir * delta

    if snapEnabled then
        local rawCenter = rawPos.X * axis.dir.X + rawPos.Y * axis.dir.Y + rawPos.Z * axis.dir.Z
        local snapped = findSnap(inst, axis, rawCenter)

        if snapped then
            local correction = snapped - rawCenter
            rawPos = rawPos + axis.dir * correction
        end
    end

    SelectionService.current.Position = rawPos
    syncPhysics(inst, rawPos)
end

function Gizmo.endDrag()
    Gizmo.dragging = nil
end

function Gizmo.tryBeginFreeDrag(mx, my)
    local inst = SelectionService.current
    if not inst then return false end

    freeSnapTargets = { X = nil, Y = nil, Z = nil }

    local ox, oy, oz, dx, dy, dz = graphics.screenPointToRay(mx, my)
    local rayOrigin = Vector3.new(ox, oy, oz)
    local rayDir = Vector3.new(dx, dy, dz)

    freeDragPlaneNormal = normalize(rayDir)
    freeDragStartObjPos = inst.Position
    Gizmo.freeDragging = true
    Gizmo.freeDragStartHit = Gizmo.rayPlaneHit(rayOrigin, rayDir, inst.Position, freeDragPlaneNormal)
    return true
end

function Gizmo.rayPlaneHit(rayOrigin, rayDir, planePoint, planeNormal)
    local denom = dot(rayDir, planeNormal)
    if math.abs(denom) < 1e-6 then return planePoint end
    local t = dot(planePoint - rayOrigin, planeNormal) / denom
    return rayOrigin + rayDir * t
end

function Gizmo.updateFreeDrag(mx, my)
    local ox, oy, oz, dx, dy, dz = graphics.screenPointToRay(mx, my)
    local rayOrigin = Vector3.new(ox, oy, oz)
    local rayDir = Vector3.new(dx, dy, dz)

    local hit = Gizmo.rayPlaneHit(rayOrigin, rayDir, freeDragStartObjPos, freeDragPlaneNormal)
    local delta = hit - Gizmo.freeDragStartHit

    local rawPos = freeDragStartObjPos + delta
    local inst = SelectionService.current

    if snapEnabled then
        for _, axis in ipairs(axes) do
            local rawCenter = rawPos.X * axis.dir.X + rawPos.Y * axis.dir.Y + rawPos.Z * axis.dir.Z
            local snapped = findSnapFree(inst, axis, rawCenter)
            if snapped then
                local correction = snapped - rawCenter
                rawPos = rawPos + axis.dir * correction
            end
        end
    end

    SelectionService.current.Position = rawPos
    syncPhysics(inst, rawPos)
end

function Gizmo.endFreeDrag()
    Gizmo.freeDragging = false
    freeSnapTargets = { X = nil, Y = nil, Z = nil }
end

return Gizmo