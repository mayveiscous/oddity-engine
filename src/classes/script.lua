local Instance = require("src.core.instance")
local Game = require("src.game")
local task = require("task")
local Vector3 = require("src.types.vector3")
local RunService = require("src.services.runservice")

local scrapi = require("src.scripting.scriptapi")

local Script = Instance:RegisterClass("Script", "Instance")

Script.Defaults = function()
    return {
        Source = "",
        _thread = nil,
    }
end

local function buildScriptEnv(self)


    local custom = scrapi.build(self)

    return setmetatable(custom, {
        __index = _G,
        __newindex = function(_, k, v)
            rawset(custom, k, v)
        end
    })
end

function Script:Init()
    self.AncestryChanged:Connect(function()
        if self.Parent then
            self:_start()
        else
            self:_stop()
        end
    end)
end

function Script:_start()
    local env = buildScriptEnv(self)
    local fn, err = load(self.Source, self.Name, "t", env)

    if not fn then
        print(("[Script:%s] failed to load: %s"):format(self.Name, err))
        return
    end

    self._thread = task.spawn(fn)
end

function Script:_stop()
    if self._thread then
        task.cancel(self._thread)
        self._thread = nil
    end
end

return Script