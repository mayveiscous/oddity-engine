local api = {}

function api.build(self)
    return {
        script = self,
        game = require("src.game"),
        workspace = require("src.game").Workspace,
        task = require("task"),
        Vector3 = require("src.types.vector3"),
        RunService = require("src.services.runservice"),
    }
end

return api