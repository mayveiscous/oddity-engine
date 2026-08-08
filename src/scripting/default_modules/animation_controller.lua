local Instance = require "src.core.instance"

local Vector3 = require "src.types.vector3"

local RunService = require "src.classes.services.runservice"

local animGet = require "src.scripting.default_modules.animGet"
local AnimationController = {}

local subject = nil
local players = {}
local current = nil

function AnimationController.Attach(character)
    subject = character
    players = {}
    current = nil
end

local function register(name)
    if not subject then 
        error("cant register animation", 2)
    end

    local aPlayer = Instance.new("AnimationPlayer")
    aPlayer.Animation = animGet.Get(name)
    aPlayer.Character = subject
    players[name] = aPlayer

    return aPlayer
end

function AnimationController.Play(name)
    if current and current == name then
        return
    end

    local player = players[name]
    if not player then
        player = register(name)

        if not player then
            error("Failed to register animation")
        end
    end

    if current and current ~= name then
        local prev = players[current]
        if prev then prev:Stop() end
    end

    player:Play()
    current = name
end

function AnimationController.Stop(name)
    local player = players[name]
    if player then
        player:Stop()
        if player.Animation then
            for motorName, _ in pairs(player.Animation.Tracks) do
                local motor = player._motorsByName and player._motorsByName[motorName]
                if motor then
                    motor.CurrentRotation = Vector3.zero()
                end
            end
        end
    end

    if current == name then
        current = nil
    end
end

function AnimationController.GetCurrent()
    return current
end

RunService.Heartbeat:Connect(function(dt)
    if current then
        local player = players[current]
        if player then
            player:Step(dt)
        end
    end
end)

return AnimationController