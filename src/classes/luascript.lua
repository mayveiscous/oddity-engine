local Instance = require("src.core.instance")
local task = require("task")
local ScriptRunner = require("src.scripting.script_runner")
local requireInstance = require("src.scripting.instance_require")

local LuaScript = Instance:RegisterClass("LuaScript", "Instance")

LuaScript.PropertyTypes = {
    Source = "string",
}

LuaScript.Defaults = function()
    return {
        Source = "",
        _thread = nil,
    }
end

LuaScript.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent",
    },
}

function LuaScript:Init()
    self.AncestryChanged:Connect(function()
        -- should i add checks for things like storage services and stuff
        if self.Parent then
            self:_start()
        else
            self:_stop()
        end
    end)
end

function LuaScript:_start()
    self._thread = ScriptRunner.RunAsync(self)
end

function LuaScript:_stop()
    if self._thread then
        task.cancel(self._thread)
        self._thread = nil
    end
end

return LuaScript