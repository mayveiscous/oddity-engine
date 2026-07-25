local InputService = require("src.classes.inputservice")
local RunService = require("src.classes.runservice")
local Game = require("src.game")
local EditorState = require("src.editor.editor_state")
local Vector3 = require("src.types.vector3")
local graphics = require("graphics")

local Camera = {}

local subject = nil

local distance = 8
local height = 1

local mouseSensitivity = 0.12
local pitchLimit = 80

local minScroll = 5
local maxScroll = 70

local defaultYaw = 90
local defaultPitch = -15
local yaw = defaultYaw
local pitch = defaultPitch

local shiftLock = false
local lastShift = false

local smoothedY = nil
local heightFollowRate = 3

local function directionFromYawPitch(yawDeg, pitchDeg)
    local yawRad = math.rad(yawDeg)
    local pitchRad = math.rad(pitchDeg)

    return Vector3.new(
        math.cos(yawRad) * math.cos(pitchRad),
        math.sin(pitchRad),
        math.sin(yawRad) * math.cos(pitchRad)
    )
end

function Camera.Attach(character)
    subject = character
end

function Camera.Detach()
    subject = nil
    smoothedY = nil
end

function Camera.GetForward()
    return directionFromYawPitch(yaw, 0)
end

function Camera.IsShiftLocked()
    return shiftLock
end

function Camera.GetYaw()
    return yaw
end

math.clamp = function(min, max, value)
    if value > max then value = max end
    if value < min then value = min end
    return value
end

local wasPlaytesting = false

RunService.Heartbeat:Connect(function(dt)
    -- this flag is only until i rewrite this inside of a LuaScript/TunaScript object
    -- as those wont connect to the engine at all
    -- and therefore, wont interfere
    -- once rewritten, this will be a production module.

    local pt = EditorState.isPlaytesting

    if not pt and wasPlaytesting then
        subject = nil
        smoothedY = nil
    end

    wasPlaytesting = pt

    if not pt or not subject then return end

    local cam = Game.CurrentCamera

    local shiftDown = InputService.IsKeyDown("LeftShift")
    if shiftDown and not lastShift then
        shiftLock = not shiftLock
        graphics.getMouseDelta()
    end
    lastShift = shiftDown

    if shiftLock or InputService.IsMouseButtonDown("Two") then
        graphics.setCursorLocked(true)

        local dx, dy = graphics.getMouseDelta()

        yaw = yaw + dx * mouseSensitivity
        pitch = pitch - dy * mouseSensitivity

        pitch = math.max(-pitchLimit, math.min(pitchLimit, pitch))
    else
        graphics.setCursorLocked(false)
    end

    local scroll = InputService.GetMouseScroll()

    if scroll ~= 0 then
        distance = math.clamp(minScroll, maxScroll, distance - scroll)
    end

    if not smoothedY then
        smoothedY = subject.Position.Y
    end

    local heightAlpha = 1 - math.exp(-heightFollowRate * dt)
    smoothedY = smoothedY + (subject.Position.Y - smoothedY) * heightAlpha

    local target = Vector3.new(subject.Position.X, smoothedY + height, subject.Position.Z)
    
    local direction = directionFromYawPitch(yaw, pitch)
    local offset = direction * distance


    local followRate = 10
    local alpha = 1 - math.exp(-followRate * dt)
    cam.Position = cam.Position:Lerp(target - offset, alpha)
    cam.LookAt = target
end)

return Camera