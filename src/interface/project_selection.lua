local ui = require "src.core.ui"
local graphics = require "graphics"
local Theme = require "src.editor.interfaces.theme"
local Projects = require "src.core.projects"

local ProjectSelection = {}

local activeTab = "New"
local selectedTemplate = nil
local newProjectName = ""
local createError = nil

local recent = nil
local selectedRecent = nil

local result = nil

local SIDEBAR_WIDTH = 200
local CARD_WIDTH, CARD_HEIGHT = 220, 130
local CARD_GAP = 16

local function refreshRecent()
    recent = Projects.listRecent()
    selectedRecent = nil
end

local function timeAgo(unixTime)
    if not unixTime or unixTime == 0 then return "" end

    local diff = os.time() - unixTime
    if diff < 60 then return "just now" end
    if diff < 3600 then return math.floor(diff / 60) .. "m ago" end
    if diff < 86400 then return math.floor(diff / 3600) .. "h ago" end
    return math.floor(diff / 86400) .. "d ago"
end

local function drawSidebar()
    ui.beginChild("Sidebar", SIDEBAR_WIDTH, 0, false)

    ui.spacing()
    ui.textColored(Theme.palette.text[1], Theme.palette.text[2], Theme.palette.text[3], 1, "ODDITY")
    ui.textColored(Theme.palette.textDim[1], Theme.palette.textDim[2], Theme.palette.textDim[3], 1, "Engine")
    ui.spacing()
    ui.separator()
    ui.spacing()

    if ui.buttonEx("New", activeTab == "New", SIDEBAR_WIDTH - 16, 32) then
        activeTab = "New"
    end

    ui.spacing()

    if ui.buttonEx("Recent", activeTab == "Recent", SIDEBAR_WIDTH - 16, 32) then
        activeTab = "Recent"
        refreshRecent()
    end

    ui.endChild()
end

local function drawTemplateCard(template)
    local isSelected = selectedTemplate == template.id

    if isSelected then
        ui.pushStyleColor("Button", Theme.palette.accentActive[1], Theme.palette.accentActive[2], Theme.palette.accentActive[3], 1)
    end

    if ui.button(template.name .. "\n\n" .. template.blurb, CARD_WIDTH, CARD_HEIGHT) then
        selectedTemplate = template.id
        newProjectName = template.name
        createError = nil
    end

    if isSelected then
        ui.popStyleColor(1)
    end
end

local function drawNewTab(contentWidth)
    ui.spacing()
    ui.text("New Project")
    ui.spacing()
    ui.separator()
    ui.spacing()

    local cols = math.max(1, math.floor(contentWidth / (CARD_WIDTH + CARD_GAP)))

    for i, template in ipairs(Projects.templates) do
        drawTemplateCard(template)

        if i % cols ~= 0 and i ~= #Projects.templates then
            ui.sameLine()
        end
    end

    if selectedTemplate then
        ui.spacing()
        ui.separator()
        ui.spacing()

        ui.text("Project name")
        local value, changed = ui.inputText("##ProjectName", newProjectName)
        if changed then
            newProjectName = value
            createError = nil
        end

        ui.spacing()

        if ui.button("Create", 120, 32) then
            local project, err = Projects.create(newProjectName, selectedTemplate)
            if project then
                result = project
            else
                createError = err
            end
        end

        if createError then
            ui.spacing()
            ui.textColored(0.9, 0.35, 0.35, 1, createError)
        end
    end
end

local function drawRecentTab()
    ui.spacing()
    ui.text("Recent Projects")
    ui.spacing()
    ui.separator()
    ui.spacing()

    if not recent then
        refreshRecent()
    end

    if #recent == 0 then
        ui.textColored(Theme.palette.textDim[1], Theme.palette.textDim[2], Theme.palette.textDim[3], 1,
            "No projects yet - create one from the New tab.")
        return
    end

    for i, project in ipairs(recent) do
        local label = project.name .. "    " .. timeAgo(project.lastOpened)

        if ui.selectable(label) then
            if selectedRecent == i then
                result = project
            else
                selectedRecent = i
            end
        end
    end

    if selectedRecent then
        ui.spacing()
        ui.separator()
        ui.spacing()

        if ui.button("Open", 120, 32) then
            result = recent[selectedRecent]
        end
    end
end

function ProjectSelection.draw()
    local w, h = graphics.getWindowSize()

    ui.setNextWindowPos(0, 0)
    ui.setNextWindowSize(w, h)

    ui.beginWindow("ProjectSelection", {"NoMove", "NoResize", "NoCollapse", "NoTitleBar"})

    drawSidebar()
    ui.sameLine()

    ui.beginChild("Content", 0, 0, false)
    if activeTab == "New" then
        drawNewTab(w - SIDEBAR_WIDTH - 32)
    else
        drawRecentTab()
    end
    ui.endChild()

    ui.endWindow()
end

function ProjectSelection.run()
    Theme.apply()

    while not result and not graphics.shouldClose() do
        graphics.pollEvents()
        graphics.beginFrame()
        ProjectSelection.draw()
        graphics.endFrame()
    end

    return result
end

return ProjectSelection
