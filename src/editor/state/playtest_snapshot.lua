local Game = require "src.game"
local task = require "task"

local Vector3 = require "src/types/vector3"

local debug = require "debug"

local Snapshot = {}

function Snapshot.Capture(workspace)
    local state = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local captured = {}
        for _, properties in pairs(obj:GetProperties()) do
            for name, value in pairs(properties) do
                if name == "ClassName" or name == "Parent" or name == "UniqueId" then 
                    goto continue
                end

                captured[name] = value

                ::continue::
            end
        end
        state[obj.UniqueId] = captured
    end

    state.cameraReturnTo = {
        Position = Vector3.new(
            Game.CurrentCamera.Position.X,
            Game.CurrentCamera.Position.Y,
            Game.CurrentCamera.Position.Z
        ),
        LookAt = Vector3.new(
            Game.CurrentCamera.LookAt.X,
            Game.CurrentCamera.LookAt.Y,
            Game.CurrentCamera.LookAt.Z
        ),
    }

    return state
end

function Snapshot.Restore(workspace, state)
    for _, obj in ipairs(workspace:GetDescendants()) do
        local saved = state[obj.UniqueId]
        if saved then
            for name, value in pairs(saved) do
                obj[name] = value
            end
        else
            obj:Destroy()
        end
    end

    if state.cameraReturnTo then
        Game.CurrentCamera.Position = state.cameraReturnTo.Position
        Game.CurrentCamera.LookAt = state.cameraReturnTo.LookAt
    end
end

return Snapshot