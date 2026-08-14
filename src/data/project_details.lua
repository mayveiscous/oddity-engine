local details = {}

details.ProjectName = nil
details.ProjectVersion = nil
details.Engine = nil

details.Settings = {
    Width = nil,
    Height = nil,
    Fullscreen = nil
}

details.Objects = {}

details.SceneName = nil
details.SceneObjects = nil

local json_obj = {}

local function getPath(path, create)
    local current = json_obj

    for key in path:gmatch("[^%.]+") do
        if current[key] == nil then
            if not create then
                return nil
            end

            current[key] = {}
        end

        current = current[key]
    end

    return current
end

function details.update(object)
    if type(object) ~= "table" then
        return nil, "Project data must be a table"
    end

    json_obj = object

    details.ProjectName = object.name
    details.ProjectVersion = object.version
    details.Engine = object.engine

    if object.settings then
        details.Settings.Width = object.settings.width
        details.Settings.Height = object.settings.height
        details.Settings.Fullscreen = object.settings.fullscreen
    end

    if object.scene then
        details.SceneName = object.scene.name
        details.SceneObjects = object.scene.objects
        details.Objects = object.scene.objects
    end

    return true
end

function details.Append(path, data)
    local target = getPath(path, true)

    if type(target) ~= "table" then
        return nil, "Append target must be a table"
    end

    if data == nil then
        return nil, "Cannot append nil"
    end

    table.insert(target, data)

    details.update(json_obj)

    return true
end

function details.Strip(path, index)
    local target = getPath(path, false)

    if target == nil then
        return nil, "Path does not exist"
    end

    if type(target) ~= "table" then
        return nil, "Strip target must be a table"
    end

    if type(index) ~= "number" then
        return nil, "Strip index must be a number"
    end

    if index < 1 or index > #target then
        return nil, "Index out of bounds"
    end

    table.remove(target, index)

    details.update(json_obj)

    return true
end

return details