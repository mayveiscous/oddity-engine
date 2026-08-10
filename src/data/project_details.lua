local details = {}

details.ProjectName = nil
details.ProjectVersion = nil
details.Engine = nil

details.Settings = {
    Width = nil,
    Height = nil,
    Fullscreen = nil
}

details.SceneName = nil
details.SceneObjects = nil


function details.update(object)
    if type(object) ~= "table" then
        return nil, "Project data must be a table"
    end

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
    end

    return true
end


return details