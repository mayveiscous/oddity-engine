local Instance = require("src.core.instance")
local AnimUtil = require("src.core.animutil")

local AnimationPlayer = Instance:RegisterClass("AnimationPlayer", "Instance")

AnimationPlayer.PropertyTypes = {
    Animation = "Instance",
    Character = "Instance",
}

AnimationPlayer.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent",
    },

    AnimationPlayer = {
        "Animation",
        "Character",
    }
}

AnimationPlayer.Defaults = function()
    return {
        Animation = nil,
        Character = nil,
        _playhead = 0,
        _motorsByName = nil,
        _playing = false,
    }
end

function AnimationPlayer:Play()
    if not self.Animation or not self.Character then
        error("AnimationPlayer:Play() requires both Animation and Character to be set", 2)
    end

    self._motorsByName = {}
    for _, obj in ipairs(self.Character:GetDescendants()) do
        if obj:IsA("Motor") and obj.Name then
            self._motorsByName[obj.Name] = obj
        end
    end

    self._playhead = 0
    self._playing = true
end

function AnimationPlayer:Stop()
    self._playing = false
end

function AnimationPlayer:Step(dt)
    if not self._playing or not self.Animation then
        return
    end

    local anim = self.Animation
    self._playhead = self._playhead + dt

    if self._playhead > anim.Length then
        if anim.Looped then
            self._playhead = self._playhead % anim.Length
        else
            self._playhead = anim.Length
            self._playing = false
        end
    end

    for motorName, track in pairs(anim.Tracks) do
        local motor = self._motorsByName[motorName]
        if motor then
            motor.CurrentRotation = AnimUtil.sampleTrack(track, self._playhead)
        end
    end
end

return AnimationPlayer