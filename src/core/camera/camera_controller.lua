local InputService = require "src.classes.inputservice"
local RunService = require "src.classes.runservice"
local EditorState = require "src.editor.editor_state"
local Game = require "src.game"
local Vector3 = require "src.types.vector3"
local graphics = require "graphics"

local debug = require "debug"

local minSpeed = 7
local maxSpeed = 100
local acceleration = 60
local deceleration = 180

local scrollDistance = 8
local shiftMultiplier = 4

local currentSpeed = minSpeed

local mouseSensitivity = 0.12
local pitchLimit = 89

local lastMouseX, lastMouseY = nil, nil

local cam = Game.CurrentCamera
local startDx = cam.LookAt.X - cam.Position.X
local startDy = cam.LookAt.Y - cam.Position.Y
local startDz = cam.LookAt.Z - cam.Position.Z

local yaw = math.deg(math.atan(startDz, startDx))
local o_yaw = yaw
local pitch = math.deg(math.asin(
    startDy / math.sqrt(startDx*startDx + startDy*startDy + startDz*startDz)
))
local o_pitch = pitch

local function normalize(v)
    local len = math.sqrt(v.X^2 + v.Y^2 + v.Z^2)
    if len == 0 then 
        return Vector3.new(0, 0, 0) 
    end

    return Vector3.new(
        v.X / len,
        v.Y / len,
        v.Z / len
    )
end

local function cross(a, b)
    return Vector3.new(
        a.Y * b.Z - a.Z * b.Y,
        a.Z * b.X - a.X * b.Z,
        a.X * b.Y - a.Y * b.X
    )
end

local function directionFromYawPitch(yawDeg, pitchDeg)
    local yawRad = math.rad(yawDeg)
    local pitchRad = math.rad(pitchDeg)

    return Vector3.new(
        math.cos(yawRad) * math.cos(pitchRad),
        math.sin(pitchRad),
        math.sin(yawRad) * math.cos(pitchRad)
    )
end

RunService.Heartbeat:Connect(function(dt)
    if EditorState.isPlaytesting then
        return
    end -- in a playtest, don't interfere with character camera controller

    local cam = Game.CurrentCamera
    local mx, my = graphics.getMousePos()

    if InputService.IsMouseButtonDown("Two") then
        graphics.setCursorLocked(true)

        if lastMouseX then
            local dx = mx - lastMouseX
            local dy = my - lastMouseY

            yaw = yaw + dx * mouseSensitivity
            pitch = pitch - dy * mouseSensitivity

            if pitch > pitchLimit then pitch = pitchLimit end
            if pitch < -pitchLimit then pitch = -pitchLimit end
        end

        local direction = directionFromYawPitch(yaw, pitch)

        cam.LookAt = Vector3.new(
            cam.Position.X + direction.X,
            cam.Position.Y + direction.Y,
            cam.Position.Z + direction.Z
        )

        lastMouseX, lastMouseY = mx, my
    else
        graphics.setCursorLocked(false)
        lastMouseX, lastMouseY = nil, nil
    end


    local forward = normalize(Vector3.new(
        cam.LookAt.X - cam.Position.X,
        cam.LookAt.Y - cam.Position.Y,
        cam.LookAt.Z - cam.Position.Z
    ))

    local right = normalize(cross(
        forward,
        Vector3.new(0, 1, 0)
    ))


    local move = Vector3.new(0, 0, 0)

    if InputService.IsKeyDown("W") then move = move + forward end
    if InputService.IsKeyDown("S") then move = move - forward end
    if InputService.IsKeyDown("D") then move = move + right end
    if InputService.IsKeyDown("A") then move = move - right end


    if move.Magnitude > 0 then
        currentSpeed = math.min(
            maxSpeed,
            currentSpeed + acceleration * dt
        )
    else
        currentSpeed = math.max(
            minSpeed,
            currentSpeed - deceleration * dt
        )
    end


    local finalSpeed = currentSpeed

    if InputService.IsKeyDown("LeftShift") then
        finalSpeed = finalSpeed / shiftMultiplier
    end


    local velocity = move * finalSpeed * dt

    cam.Position = Vector3.new(
        cam.Position.X + velocity.X,
        cam.Position.Y + velocity.Y,
        cam.Position.Z + velocity.Z
    )

    local direction = directionFromYawPitch(yaw, pitch)
    cam.LookAt = Vector3.new(
        cam.Position.X + direction.X,
        cam.Position.Y + direction.Y,
        cam.Position.Z + direction.Z
    )

    local scroll = InputService.GetMouseScroll()

    if scroll ~= 0 then
        local distance = math.max(
            scrollDistance,
            currentSpeed * 0.15
        )

        local offset = forward * scroll * distance

        cam.Position = Vector3.new(
            cam.Position.X + offset.X,
            cam.Position.Y + offset.Y,
            cam.Position.Z + offset.Z
        )

        cam.LookAt = Vector3.new(
            cam.LookAt.X + offset.X,
            cam.LookAt.Y + offset.Y,
            cam.LookAt.Z + offset.Z
        )
    end
end)