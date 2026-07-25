local SelectionService = require("src.classes.selectionservice")
local Vector3 = require("src.types.vector3")

local graphics = require("graphics")

local Gizmo = {}

local axisLength = 2
local axisThickness = 0.15

local axes = {
    { id = "gizmo_move_x", dir = Vector3.new(1, 0, 0), color = {1, 0.2, 0.2} },
    { id = "gizmo_move_y", dir = Vector3.new(0, 1, 0), color = {0.2, 1, 0.2} },
    { id = "gizmo_move_z", dir = Vector3.new(0, 0, 1), color = {0.2, 0.4, 1} },
}

local function dot(a, b)
    return a.X * b.X + a.Y * b.Y + a.Z * b.Z
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
    if math.abs(denom) < 1e-7 then
        return 0
    end

    return (b * d - a * e) / denom
end


function Gizmo.draw(blockMeshId)
    local inst = SelectionService.current
    if not inst or not inst.Position then return end

    for _, axis in ipairs(axes) do
        local center = inst.Position + axis.dir * (axisLength / 2)
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
    local delta = current - Gizmo.dragStartOffset

    SelectionService.current.Position = Gizmo.dragStartPos + axis.dir * delta
end

function Gizmo.endDrag()
    Gizmo.dragging = nil
end

return Gizmo