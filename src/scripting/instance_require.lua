local moduleCache = {}

local function requireInstance(moduleScript)
    if type(moduleScript) ~= "table" or not moduleScript.IsA then
        error("require() expects a Module instance, not a string path", 2)
    end
    if not moduleScript:IsA("Module") then
        error(("require() expects a Module, got %s"):format(moduleScript.ClassName), 2)
    end

    local cached = moduleCache[moduleScript.UniqueId]
    if cached ~= nil then
        return cached
    end
    
    local ScriptRunner = require "src.scripting.script_runner"

    local result = ScriptRunner.RunSync(moduleScript)
    moduleCache[moduleScript.UniqueId] = result
    return result
end

return requireInstance