local api = {}

function api.build(self)
    return {
        script = self,
        task = require("task"),
        require = require("scr.scripting.require_instance"),
        Instance = require("src.core.instance"),

        Vector3 = require("src.types.vector3"),
        Vector2 = require("src.types.vector2"),
        Color3 = require("src.types.color3"),
        
        game = require("src.game"),
        RunService = require("src.classes.runservice"),
        InputService = require("src.classes.inputservice"),
        SelectionService = require("src.classes.selectionservice"),
        Workspace = require("src.classes.workspace"),
    }
end

return api          