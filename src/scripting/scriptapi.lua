local api = {}

function api.build(self)
    return {
        script = self,
        task = require "oddity.task",
        require = require "src.scripting.instance_require",

        Instance = require "src.core.instance",
        Vector3 = require "src.types.vector3",
        Vector2 = require "src.types.vector2",
        Color3 = require "src.types.color3",
        Enum = require "src.types.enum"
        Range = require "src.types.range",
        Keyframe = require "src.types.keyframe",
        
        game = require "src.game",
        RunService = require "src.classes.services.runservice",
        InputService = require "src.classes.services.inputservice",
        SelectionService = require "src.classes.services.selectionservice",
        Workspace = require "src.classes.workspace",
    }
end

return api          