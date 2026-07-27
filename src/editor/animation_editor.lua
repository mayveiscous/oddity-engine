local graphics = require "graphics"
local Instance = require "src.core.instance"
local Vector3 = require "src.types.vector3"
local Game = require "src.game"
local Log = require "src.editor.log"
local SelectionService = require "src.classes.selectionservice"

local AnimationEditor = {}

local visible = false
local selectedAnim = nil
local playhead = 0
local playing = false
local trackToAdd = ""
local newAnimName = "NewAnimation"
local lastTime = nil

function AnimationEditor.toggle()
    visible = not visible
end

function AnimationEditor.isVisible()
    return visible
end

local function getSortedTrackNames()
    local names = {}
    for name in pairs(selectedAnim.Tracks) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

local function drawTopBar()
    if graphics.imguiButton("New") then
        local anim = Instance.new("Animation")
        anim.Name = newAnimName
        anim.Parent = Game.Workspace
        selectedAnim = anim
        playhead = 0
        playing = false
        Log.info("Created animation: " .. newAnimName)
    end

    graphics.imguiSameLine()
    newAnimName = graphics.imguiInputText("##newname", newAnimName)

    if selectedAnim then
        graphics.imguiSeparator()
        graphics.imguiText("Editing: " .. selectedAnim.Name)

        local newLen, lenChanged = graphics.imguiInputFloat("Length", selectedAnim.Length)
        if lenChanged then
            selectedAnim.Length = math.max(0.01, newLen)
            if playhead > selectedAnim.Length then
                playhead = selectedAnim.Length
            end
        end

        graphics.imguiSameLine()
        local looped, lchanged = graphics.imguiCheckbox("Looped", selectedAnim.Looped)
        if lchanged then
            selectedAnim.Looped = looped
        end
    end
end

local function drawTimeline()
    if not selectedAnim then return end

    graphics.imguiText("Timeline")
    graphics.imguiSeparator()

    local length = selectedAnim.Length
    if length <= 0 then length = 1 end

    graphics.imguiText("          ")
    local step = 0.25
    local t = 0
    while t <= length + 0.001 do
        graphics.imguiText(string.format("%.2f", t))
        graphics.imguiSameLine()
        t = t + step
    end

    for _, motorName in ipairs(getSortedTrackNames()) do
        local track = selectedAnim.Tracks[motorName]
        graphics.imguiText(string.format("%-10s", motorName))
        for i, kf in ipairs(track) do
            local label = string.format("%.2f##%s%d", kf.time, motorName, i)
            if graphics.imguiSelectable(label) then
                playhead = kf.time
            end
            graphics.imguiSameLine()
        end
    end
end

local function drawPlayback()
    if not selectedAnim then return end

    if graphics.imguiButton(playing and "Stop" or "Play") then
        playing = not playing
        if playing then
            playhead = 0
        end
    end

    graphics.imguiSameLine()
    graphics.imguiText(string.format("%.2f / %.2f", playhead, selectedAnim.Length))

    graphics.imguiSameLine()
    local newTime, changed = graphics.imguiInputFloat("##playhead", playhead)
    if changed then
        playhead = math.max(0, math.min(newTime, selectedAnim.Length))
    end
end

local function drawTrackEditor()
    if not selectedAnim then return end

    graphics.imguiText("Tracks")
    graphics.imguiSeparator()

    trackToAdd = graphics.imguiInputText("##trackname", trackToAdd)
    graphics.imguiSameLine()
    if graphics.imguiButton("Add Track") and trackToAdd ~= "" then
        if not selectedAnim.Tracks[trackToAdd] then
            selectedAnim.Tracks[trackToAdd] = {}
            Log.info("Added track: " .. trackToAdd)
            trackToAdd = ""
        end
    end

    local tracksToRemove = nil
    for _, motorName in ipairs(getSortedTrackNames()) do
        local track = selectedAnim.Tracks[motorName]
        local headerLabel = motorName .. " (" .. #track .. " keyframes)"
        if graphics.imguiCollapsingHeader(headerLabel, true) then
            local kfsToRemove = nil
            for i, kf in ipairs(track) do
                graphics.imguiText(string.format("KF %d", i))

                graphics.imguiSameLine()
                local newTime, tchanged = graphics.imguiInputFloat(
                    "Time##" .. motorName .. i, kf.time
                )
                if tchanged then
                    kf.time = math.max(0, math.min(newTime, selectedAnim.Length))
                end

                local rx, ry, rz, rchanged = graphics.imguiVector3(
                    "Rot##" .. motorName .. i,
                    kf.rotation.X, kf.rotation.Y, kf.rotation.Z
                )
                if rchanged then
                    kf.rotation = Vector3.new(rx, ry, rz)
                end

                graphics.imguiSameLine()
                if graphics.imguiButton("X##rm" .. motorName .. i) then
                    kfsToRemove = kfsToRemove or {}
                    table.insert(kfsToRemove, i)
                end
            end

            if kfsToRemove then
                for j = #kfsToRemove, 1, -1 do
                    table.remove(track, kfsToRemove[j])
                end
            end

            if graphics.imguiButton("Add Keyframe##" .. motorName) then
                table.insert(track, { time = playhead, rotation = Vector3.new(0, 0, 0) })
                table.sort(track, function(a, b) return a.time < b.time end)
                Log.info("Added keyframe to " .. motorName)
            end

            graphics.imguiSameLine()
            if graphics.imguiButton("Remove Track##" .. motorName) then
                tracksToRemove = tracksToRemove or {}
                table.insert(tracksToRemove, motorName)
            end
        end
    end

    if tracksToRemove then
        for _, name in ipairs(tracksToRemove) do
            selectedAnim.Tracks[name] = nil
            Log.info("Removed track: " .. name)
        end
    end

    graphics.imguiSeparator()
    if graphics.imguiButton("Delete Animation") then
        selectedAnim:Destroy()
        selectedAnim = nil
        playing = false
        Log.info("Deleted animation")
    end
end

function AnimationEditor.draw()
    if not visible then return end

    local current = SelectionService.current
    if current and current.ClassName == "Animation" and current ~= selectedAnim then
        selectedAnim = current
        playhead = 0
        playing = false
    end

    if selectedAnim and not selectedAnim.Parent then
        selectedAnim = nil
        playing = false
    end

    local now = os.clock()
    local dt = lastTime and (now - lastTime) or 0
    lastTime = now

    if playing and selectedAnim then
        playhead = playhead + dt
        if playhead > selectedAnim.Length then
            if selectedAnim.Looped then
                playhead = playhead % selectedAnim.Length
            else
                playhead = selectedAnim.Length
                playing = false
            end
        end
    end

    graphics.imguiBegin("Animation Editor")

    drawTopBar()

    if selectedAnim then
        graphics.imguiSeparator()
        drawTimeline()
        graphics.imguiSeparator()
        drawPlayback()
        graphics.imguiSeparator()
        drawTrackEditor()
    else
        graphics.imguiText("Select an Animation in Explorer or click New to create one.")
    end

    graphics.imguiEnd()
end

return AnimationEditor