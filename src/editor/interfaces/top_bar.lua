local ui = require "src.core.ui"
local AnimationEditor = require "src.editor.interfaces.animation_editor"
local TextEditor = require "src.editor.interfaces.text_editor"

local EditorState = require "src.editor.state"
local Snapshot = require "src.editor.state.playtest_snapshot"

local PhysicsEngine = require "src.physics.core.engine"
local PhysicsObject = require "src.physics.core.physics_object"

local Log = require "src.editor.state.log"
local Tabs = require "src.editor.state.tabs"

local Game = require "src.game"

local TopBar = {}

local playing = false

local function beginPlaytestScripts()
    for _, obj in ipairs(Game:GetDescendants()) do
        if obj:IsA("LuaScript") then
            obj:UpdateRunning()
        end
    end
end

local function stopPlaytestScripts()
    for _, obj in ipairs(Game:GetDescendants()) do
        if obj:IsA("LuaScript") then
            obj:_stop()
        end
    end
end

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

local function beginPlaytest()
    local CreateCharacter = require "src.create_character"

    EditorState.playtestSnapshot = Snapshot.Capture(Game.Workspace)

    for _, player in pairs(Game.Players:GetChildren()) do
        CreateCharacter.createCharacter(player)
    end

    beginPlaytestPhysics()

    Log.clear()

    Tabs.setActiveIndex(Tabs.getSceneIndex())
    Game.beginPlaytest()
    EditorState.StartPlaytest()
    beginPlaytestScripts()
end

local function stopPlaytest()
    stopPlaytestScripts()

    Snapshot.Restore(Game.Workspace, EditorState.playtestSnapshot)

    TextEditor.discardPendingEdits()

    Game.stopPlaytest()
    EditorState.StopPlaytest()
end

local function drawPlayButton()
    local isPlaying = EditorState.isPlaytesting

    if isPlaying then
        if ui.buttonEx("Stop", false, 70, 28) then
            stopPlaytest()
        end
    else
        if ui.buttonEx("Play", false, 70, 28) then
            beginPlaytest()
        end
    end
end

local function drawToolButton(name)
    local selected = EditorState.CurrentTool == name

    if ui.buttonEx(name, selected, 70, 28) then
        EditorState.CurrentTool = name
    end
end

local function drawToolbar()
    drawPlayButton()

    ui.sameLine()

    drawToolButton("Select")

    ui.sameLine()

    drawToolButton("Move")

    ui.sameLine()

    drawToolButton("Scale")

    ui.sameLine()

    drawToolButton("Rotate")

    ui.sameLine()

    ui.separator()

    ui.sameLine()

    ui.text(EditorState.isPlaytesting and "PLAYING" or "EDITING")
end

function TopBar.draw(rects)
    ui.setNextWindowPos(rects.x, rects.y)
    ui.setNextWindowSize(rects.w, rects.h)

    ui.beginWindow("Top Bar", {"NoMove", "NoResize", "NoTitleBar"})

    drawToolbar()

    ui.endWindow()
end

return TopBar

--[[

local block = Instance.new("Block")
block.Parent = game.Workspace

while true do
   block.Position = block.Position + Vector3.new(0, 1, 0)
   task.wait(1)
end

]]