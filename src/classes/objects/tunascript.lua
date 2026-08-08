local Instance = require "src.core.instance"
local Game = require "src.game"
local task = require "task"

local ScriptRunner = require "src.scripting.script_runner"
local requireInstance = require "src.scripting.instance_require"

local scrapi = require "src.scripting.scriptapi"

local TunaScript = Instance:RegisterClass("TunaScript", "Instance")

TunaScript.Defaults = function()
    return {
        Source = "",
        _thread = nil,
    }
end

TunaScript.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent",
    },
}

local function buildScriptEnv(self)
    local custom = scrapi.build(self)

    local realRequire = _G.require

    custom.require = function(mod)
        if type(mod) == "table" and mod.ClassName and mod.Parent then
            return mod
        end
        return realRequire(mod)
    end

    return setmetatable(custom, {
        __index = _G,
        __newindex = function(_, k, v)
            rawset(custom, k, v)
        end
    })
end

function TunaScript:Init()
    self.AncestryChanged:Connect(function()
        if self.Parent then
            self:_start()
        else
            self:_stop()
        end
    end)
end

function TunaScript:_start()
    self._thread = ScriptRunner.RunAsync(self)
end

function TunaScript:_stop()
    if self._thread then
        task.cancel(self._thread)
        self._thread = nil
    end
end

return TunaScript