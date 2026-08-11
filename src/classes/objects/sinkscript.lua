local Instance = require "src.core.instance"
local task = require "oddity.task"

local ScriptRunner = require "src.scripting.script_runner"

local EditorState = require "src.editor.state"
local TextEditor = require "src.editor.interfaces.text_editor"

local SinkScript = Instance:RegisterClass("SinkScript", "Instance", {
    Properties = {
        Source = {
            type = "string",
            default = [[outln -> "Hello Sink!"]],
            category = "Hidden",
        },

        CoreScript = {
            type = "boolean",
            default = false,
            category = "Script",
            ReadOnly = true,
        },
    },
})

function SinkScript:UpdateRunning()
    if not self.Parent then
        self:_stop()
        return
    end

    if EditorState.isPlaytesting and not self:ScriptsBlocked() then
        self:_start()
    else
        self:_stop()
    end
end

function SinkScript:Init()
    local hasOpened = false

    self.AncestryChanged:Connect(function()
        if self.Parent then
            if not hasOpened then
                hasOpened = true

                if not self.CoreScript then
                    TextEditor.openScript(self)
                end
            end

            self:UpdateRunning()
        else
            self:_stop()
            TextEditor.closeScript(self)
        end
    end)

    self:OnPropertyChanged("Name"):Connect(function()
        TextEditor.updateScript(self)
    end)

    self:OnPropertyChanged("BlockScripts"):Connect(function()
        self:UpdateRunning()
    end)
end

function SinkScript:_start()
    if self._running then return end

    self._running = true
    self._thread = ScriptRunner.RunAsync(self)
end

function SinkScript:_stop()
    if not self._running then return end

    self._running = false

    if self._thread then
        task.cancel(self._thread)
        self._thread = nil
    end
end

return SinkScript