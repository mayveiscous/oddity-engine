local Instance = require "src.core.instance"
local task = require "task"
local ScriptRunner = require "src.scripting.script_runner"
local requireInstance = require "src.scripting.instance_require"

local EditorState = require "src.editor.state.layout"
local TextEditor = require "src.editor.interfaces.text_editor"

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
        if self.Parent then
            if EditorState.isPlaytesting then
                self:_start()
            else
                self:_stop()
            end
        else
            self:_stop()
            TextEditor.closeScript(self)
        end
    end)

    TextEditor.openScript(self)

    self:OnPropertyChanged("Name"):Connect(function()
        TextEditor.updateScript(self)
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