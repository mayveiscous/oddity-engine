local graphics = require "graphics"
local ProjectSelection = require "src.interface.project_selection"

local function loadProject(project)
    require "src.classes"

    require "src.core.camera.camera_controller"
    require "src.scripting.default_modules.character_camera"

    local RunService = require "src.classes.services.runservice"
    RunService:Init()

    require "src.editor.state.selection"

    require "src.create-runtime.baseplate"
    require "src.game"

    RunService:Run()
end

graphics.init()

local project = ProjectSelection.run()

if project then
    loadProject(project)
end