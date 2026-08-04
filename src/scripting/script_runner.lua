local task = require "task"
local Log = require "src.editor.state.log"

local ScriptRunner = {}

local function buildEnv(self)
    local scriptapi = require "src.scripting.scriptapi"
    local requireInstance = require "src.scripting.instance_require"

    local custom = scriptapi.build(self)
    custom.script = self
    custom.require = requireInstance

    return setmetatable(custom, {
        __index = _G,
        __newindex = function(_, k, v)
            rawset(custom, k, v)
        end
    })
end

function ScriptRunner.Compile(instance)
    local env = buildEnv(instance)
    local fn, err = load(instance.Source, instance.Name, "t", env)
    return fn, err
end

function ScriptRunner.RunAsync(instance)
    local fn, err = ScriptRunner.Compile(instance)
    if not fn then
        Log.error(("[%s:%s] failed to load: %s"):format(instance.ClassName, instance.Name, err))
        return nil
    end
    return task.spawn(fn)
end

function ScriptRunner.RunSync(instance)
    local fn, err = ScriptRunner.Compile(instance)
    if not fn then
        Log.error(("[%s:%s] failed to load: %s"):format(instance.ClassName, instance.Name, err))
        error(("[%s:%s] failed to load: %s"):format(instance.ClassName, instance.Name, err), 0)
    end
    return fn()
end

return ScriptRunner