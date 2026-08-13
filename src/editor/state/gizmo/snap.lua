local Math = require "src.editor.state.gizmo.math"

local Snap = {}

function Snap.newState()
    return {
        X = nil,
        Y = nil,
        Z = nil,
    }
end

function Snap.clear(state)
    state.X = nil
    state.Y = nil
    state.Z = nil
end

function Snap.find(inst, axis, rawCenter, previousTarget, objects, threshold, releaseThreshold)
    if previousTarget then
        if math.abs(previousTarget - rawCenter) < releaseThreshold then
            return previousTarget
        end
    end

    local half = Math.getAxisHalfSize(inst.Size, axis)

    local best = nil
    local bestDelta = threshold

    for _, obj in ipairs(objects) do
        if obj ~= inst and obj.Position and obj.Size then
            local min, max, center = Math.getAxisExtents(obj.Position, obj.Size, axis)

            local candidates = {
                max - half,
                min + half,
                min - half,
                max + half,
                center,
            }

            for _, candidate in ipairs(candidates) do
                local delta = math.abs(candidate - rawCenter)

                if delta < bestDelta then
                    bestDelta = delta
                    best = candidate
                end
            end
        end
    end

    return best
end

function Snap.apply(inst, axis, position, state, objects, threshold, releaseThreshold)
    local rawCenter = Math.getAxisCenter(position, axis)
    local previousTarget = state[axis.key]

    local snapped = Snap.find(
        inst,
        axis,
        rawCenter,
        previousTarget,
        objects,
        threshold,
        releaseThreshold
    )

    state[axis.key] = snapped

    if not snapped then
        return position
    end

    return position + axis.direction * (snapped - rawCenter)
end

return Snap