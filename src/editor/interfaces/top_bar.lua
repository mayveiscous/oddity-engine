local graphics = require "graphics"
local AnimationEditor = require "src.editor.interfaces.animation_editor"

local EditorState = require "src.editor.state"
local Snapshot = require "src.editor.state.playtest_snapshot"

local PhysicsEngine = require "src.physics.core.engine"
local PhysicsObject = require "src.physics.core.physics_object"

local Game = require "src.game"

local TopBar = {}

local currentTool = "Select"
local playing = false

local function beginPlaytestPhysics()
    PhysicsEngine.Clear()

    local characters = {}
    for _, obj in ipairs(Game.Workspace:GetDescendants()) do
        if obj:IsA("Character") then
            table.insert(characters, obj)
        end
    end

    local function isNonRootCharacterBlock(obj)
        for _, character in ipairs(characters) do
            if obj ~= character.RootPart and obj:IsDescendantOf(character) then
                return true
            end
        end
        return false
    end

    for _, obj in ipairs(Game.Workspace:GetDescendants()) do
        if obj:IsA("Block") and obj.Anchored == false and not isNonRootCharacterBlock(obj) then
            PhysicsEngine.AddObject(PhysicsObject.fromPart(obj))
        end
    end
end

function TopBar.draw(rects)
    graphics.imguiSetNextWindowPos(rects.x, rects.y)
    graphics.imguiSetNextWindowSize(rects.w, rects.h)

    graphics.imguiBegin("Top Bar", {"NoMove", "NoResize", "NoTitleBar"})

    local label = EditorState.isPlaytesting and "Stop" or "Play"

    if graphics.imguiButtonEx(EditorState.isPlaytesting and "Stop" or "Play", false, 70, 24) then
        if EditorState.isPlaytesting then
            Snapshot.Restore(Game.Workspace, EditorState.playtestSnapshot)
            EditorState.StopPlaytest()
        else
            local CreateCharacter = require "src.create_character"
            EditorState.playtestSnapshot = Snapshot.Capture(Game.Workspace)

            for _, player in pairs(Game.Players.Players) do
                CreateCharacter.createCharacter(player)
            end

            beginPlaytestPhysics()
            EditorState.StartPlaytest()
        end
    end

    graphics.imguiEnd()
end

return TopBar