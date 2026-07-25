local graphics = require("graphics")
local AnimationEditor = require("src.editor.animation_editor")

local EditorState = require("src.editor.editor_state")
local Snapshot = require("src.editor.playtest_snapshot")


local Game = require("src.game")

local TopBar = {}

local currentTool = "Select"
local playing = false

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
            local CreateCharacter = require("src.create_character")
            EditorState.playtestSnapshot = Snapshot.Capture(Game.Workspace)
            for _, player in pairs(Game.Players.Players) do
                CreateCharacter.createCharacter(player)
            end
            EditorState.StartPlaytest()
        end
    end
    graphics.imguiEnd()
end

return TopBar