local Snapshot = {}

function Snapshot.Capture(workspace)
    local state = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local captured = {}
        for _, properties in pairs(obj:GetProperties()) do
            for name, value in pairs(properties) do
                if name == "ClassName" then 
                    goto continue
                end

                captured[name] = value

                ::continue::
            end
        end
        state[obj.UniqueId] = captured
    end
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
end

return Snapshot