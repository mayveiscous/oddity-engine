local InputService = require("src.classes.inputservice")
local RunService = require("src.classes.runservice")
local Game = require("src.game")
local Vector3 = require("src.types.vector3")
local render = require("render")

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

local lastMouseX, lastMouseY = nil, nil


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

function Camera.GetForward()
    return directionFromYawPitch(yaw, 0)
end

math.clamp = function(min, max, value)
    if value > max then value = max end
    if value < min then value = min end
    return value
end

RunService.Heartbeat:Connect(function(dt)
    if not subject then
        return
    end

    local cam = Game.CurrentCamera

    local mx, my = render.getMousePos()

    if InputService.IsMouseButtonDown("Two") then
        render.setCursorLocked(true)

        if lastMouseX then
            local dx = mx - lastMouseX
            local dy = my - lastMouseY

            yaw = yaw + dx * mouseSensitivity
            pitch = pitch - dy * mouseSensitivity

            pitch = math.max(
                -pitchLimit,
                math.min(pitchLimit, pitch)
            )
        end

        lastMouseX = mx
        lastMouseY = my
    else
        local alpha = math.min(dt * 5, 1)

        yaw = yaw + (defaultYaw - yaw) * alpha
        pitch = pitch + (defaultPitch - pitch) * alpha

        render.setCursorLocked(false)
        lastMouseX = nil
        lastMouseY = nil
    end

    local scroll = InputService.GetMouseScroll()

    if scroll ~= 0 then
        distance = math.clamp(minScroll, maxScroll, distance - scroll)
    end

    local target = subject.Position + Vector3.new(0, height, 0)
    local direction = directionFromYawPitch(yaw, pitch)
    local offset = direction * distance

    cam.Position = cam.Position:Lerp(target - offset, dt * 10)
    cam.LookAt = target
end)

return Camera