local Signal = require "signal"
local task = require "task"
local graphics = require "graphics"

local Vector3 = require "src.types.vector3"
local AnimUtil = require "src.core.animutil"

local EditorUI = require"src.editor.load"
local EditorState = require "src.editor.editor_state"
local Highlighter = require "src.editor.highlighter"

-- local PhysicsRuntime = require "src.physics.physics_runtime"
local PhysicsEngine = require "src.physics.core.engine"
local PhysicsObject = require "src.physics.core.physics_object"

local Game = require "src.game"

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

local function updateBodyMotor(character)
    local hitbox = character.RootPart
    if not hitbox then return end

    local body = character:FindFirstChild("Body")
    local motor = hitbox:FindFirstChild("BodyMotor")
    if not (body and motor) then return end

    body.Position = hitbox.Position + AnimUtil.rotateVector3(motor.C0, hitbox.Rotation)
    body.Rotation = hitbox.Rotation
end

function RunService:Init()
    graphics.init()
end

function RunService:Step()
    if not running then return end

    lastTime = lastTime or os.clock()
    local now = os.clock()
    local dt = now - lastTime

    local opaque, transparent, motors, characters, forces = {}, {}, {}, {}, {}

    graphics.clearPointLights()
    graphics.clearSpotLights()

    -- collection
    for _, obj in ipairs(Game.Workspace:GetDescendants()) do
        if obj:IsA("PointLight") and obj.Enabled then
            graphics.addPointLight(
                obj.Position.X, obj.Position.Y, obj.Position.Z,
                obj.Color.R, obj.Color.G, obj.Color.B
            )

        elseif obj:IsA("SpotLight") and obj.Enabled then
            graphics.addSpotLight(
                obj.Position.X, obj.Position.Y, obj.Position.Z,
                obj.Direction.X, obj.Direction.Y, obj.Direction.Z,
                obj.Color.R, obj.Color.G, obj.Color.B,
                obj.InnerAngle, obj.OuterAngle
            )

        elseif obj:IsA("Motor") then
            if obj.Name ~= "BodyMotor" then
                table.insert(motors, obj)
            end

        elseif obj:IsA("Character") then
            table.insert(characters, obj)

        elseif obj:IsA("Force") and obj.Enabled then
            table.insert(forces, obj)
        end
    end

    task.update()
    RunService.Heartbeat:Fire(dt)

    -- physics
    if EditorState.isPlaytesting then
            local colliders = {}
        for _, obj in ipairs(Game.Workspace:GetDescendants()) do
            if obj.CanCollide and obj.Anchored then
                table.insert(colliders, obj)
            end
        end

        PhysicsEngine.Simulate(dt, colliders)

        for _, character in ipairs(characters) do
            updateBodyMotor(character)
        end

        updateMotors(motors)

        -- apply forces (BodyVelocity-style)
        for _, force in ipairs(forces) do
            local parent = force.Parent
            if parent and parent.Position then
                local vel = force.Velocity
                local max = force.MaxForce

                local pos = parent.Position
                parent.Position = Vector3.new(
                    pos.X + ((max.X ~= 0) and vel.X or 0) * dt,
                    pos.Y + ((max.Y ~= 0) and vel.Y or 0) * dt,
                    pos.Z + ((max.Z ~= 0) and vel.Z or 0) * dt
            )
            end
        end
    end
 
    graphics.beginFrame()

    -- draw ui
    EditorUI.draw(Game.Workspace)

    -- camera
    if Game.CurrentCamera then
        local cam = Game.CurrentCamera
        graphics.setCamera(
            cam.Position.X,
            cam.Position.Y,
            cam.Position.Z,
            cam.LookAt.X,
            cam.LookAt.Y,
            cam.LookAt.Z
        )
    end

    -- lighting
    if Game.Lighting then
        local light = Game.Lighting
        graphics.setLight(
            light.Direction.X,
            light.Direction.Y,
            light.Direction.Z,
            light.Color.R,
            light.Color.G,
            light.Color.B
        )
    end

    -- collect meshes
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
    end

    -- highlight selected obj
    Highlighter.draw()

    -- graphics opaque
    for _, obj in ipairs(opaque) do
        graphics.drawMesh(
            obj._meshId,
            obj.Position.X, obj.Position.Y, obj.Position.Z,
            obj.Size.X, obj.Size.Y, obj.Size.Z,
            obj.Color.R, obj.Color.G, obj.Color.B,
            obj.Rotation.X, obj.Rotation.Y, obj.Rotation.Z,
            1,
            obj.UniqueId
        )
    end

    -- graphics transparent
    for _, obj in ipairs(transparent) do
        graphics.drawMesh(
            obj._meshId,
            obj.Position.X, obj.Position.Y, obj.Position.Z,
            obj.Size.X, obj.Size.Y, obj.Size.Z,
            obj.Color.R, obj.Color.G, obj.Color.B,
            obj.Rotation.X, obj.Rotation.Y, obj.Rotation.Z,
            1 - obj.Transparency,
            obj.UniqueId
        )
    end

    graphics.endFrame()
    graphics.pollEvents()

    lastTime = now
end

function RunService:Run()
    running = true
    lastTime = os.clock()

    while running and not graphics.shouldClose() do
        self:Step()
    end
end

function RunService:Stop()
    running = false
end

return RunService