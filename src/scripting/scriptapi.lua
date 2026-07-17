local api = {}

function api.build(self)
    return {
        script = self,
        task = require("task"),

        Vector3 = require("src.types.vector3"),
        
        game = require("src.game"),
        RunService = require("src.classes.runservice"),
        Workspace = require("src.classes.workspace"),
    }
end

return api