local Signal = require("src.core.signal")
local task = require("task")
local render = require("render")

local Vector3 = require("src.types.vector3")
local AnimUtil = require("src.core.animutil")

local Game = require("src.game")

local RunService = {}

RunService.Heartbeat = Signal.new()

local running = false
local lastTime = nil

local function updateMotors(AllMotors)
    for _, motor in ipairs(AllMotors) do
        if motor.Part0 and motor.Part1 then
            local totalRotation = Vector3.new(
                motor.Part0.Rotation.X + motor.RestRotation.X + motor.CurrentRotation.X,
                motor.Part0.Rotation.Y + motor.RestRotation.Y + motor.CurrentRotation.Y,
                motor.Part0.Rotation.Z + motor.RestRotation.Z + motor.CurrentRotation.Z
            )

            local rotatedC0 = AnimUtil.rotateVector3(motor.C0, motor.Part0.Rotation)
            local pivotWorld = motor.Part0.Position + rotatedC0

            local rotatedC1 = AnimUtil.rotateVector3(motor.C1, totalRotation)
            motor.Part1.Position = pivotWorld - rotatedC1

            motor.Part1.Rotation = totalRotation
        end
    end
end

function RunService:Init()
    render.init()
end

function RunService:Step()
    if not running then return end

    -- compute dt
    lastTime = lastTime or os.clock()
    local now = os.clock()
    local dt = now - lastTime
    
    -- start renderer frame
    render.beginFrame()

    -- position the camera
    if Game.CurrentCamera then
        local cam = Game.CurrentCamera
        render.setCamera(cam.Position.X, cam.Position.Y, cam.Position.Z, cam.LookAt.X, cam.LookAt.Y, cam.LookAt.Z)
    end

    if Game.Lighting then
        local light = Game.Lighting
        render.setLight(
            light.Direction.X, light.Direction.Y, light.Direction.Z,
            light.Color.R, light.Color.G, light.Color.B
        )
    end

    -- draw all objects
    local opaque, transparent, motors = {}, {}, {}

    for _, obj in ipairs(Game.Workspace:GetDescendants()) do
        if obj.EnsureMesh then
            local meshId = obj:EnsureMesh()
            if meshId then
                if obj.Transparency and obj.Transparency > 0 then
                    table.insert(transparent, obj)
                else
                    table.insert(opaque, obj)
                end
            end
        end

        if obj:IsA("Motor") then
            table.insert(motors, obj)
        end
    end

    for _, obj in ipairs(opaque) do
        render.drawMesh(
            obj._meshId, 
            obj.Position.X, obj.Position.Y, obj.Position.Z,
            obj.Size.X, obj.Size.Y, obj.Size.Z, 
            obj.Color.R, obj.Color.G, obj.Color.B, 
            obj.Rotation.X, obj.Rotation.Y, obj.Rotation.Z, 
            1
        )
    end

    for _, obj in ipairs(transparent) do 
        render.drawMesh(
            obj._meshId,
            obj.Position.X, obj.Position.Y, obj.Position.Z,
            obj.Size.X, obj.Size.Y, obj.Size.Z,
            obj.Color.R, obj.Color.G, obj.Color.B,
            obj.Rotation.X, obj.Rotation.Y, obj.Rotation.Z,
            1 - obj.Transparency
        )
    end

    updateMotors(motors)

    -- fire heartbeat signal
    -- for script objects
    task.update()
    RunService.Heartbeat:Fire(dt)

    -- end frame
    render.endFrame()
    render.pollEvents()

    lastTime = now
end

function RunService:Run()
    running = true
    lastTime = os.clock()

    while running and not render.shouldClose() do
        self:Step()
    end
end

function RunService:Stop()
    running = false
end

return RunService