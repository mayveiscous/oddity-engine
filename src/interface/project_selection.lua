local ui = require "src.core.ui"
local graphics = require "oddity.graphics"
local Theme = require "src.editor.interfaces.theme"
local Projects = require "src.core.projects"

local Build = require "src.create-runtime.build"

local ProjectSelection = {}

local activeTab = "Recent"
local selectedTemplate = nil
local newProjectName = ""
local createError = nil

local recent = nil
local selectedRecent = nil

local shouldFocus = false

local result = nil

local SIDEBAR_WIDTH = 200
local CONTENT_PADDING = 28

local CARD_WIDTH = 220
local CARD_HEIGHT = 130
local CARD_GAP = 12

local function refreshRecent()
    recent = Projects.listRecent()
    selectedRecent = nil
end

local function timeAgo(unixTime)
    if not unixTime or unixTime == 0 then
        return ""
    end

    local diff = os.time() - unixTime

    if diff < 60 then
        return "just now"
    end

    if diff < 3600 then
        return math.floor(diff / 60) .. "m ago"
    end

    if diff < 86400 then
        return math.floor(diff / 3600) .. "h ago"
    end

    return math.floor(diff / 86400) .. "d ago"
end

local function text(text, color)
    color = color or Theme.palette.text

    ui.textColored(
        color[1],
        color[2],
        color[3],
        color[4],
        text
    )
end

local function drawSidebar()
    ui.beginChild("Sidebar", SIDEBAR_WIDTH, 0, false)

    ui.spacing()
    ui.spacing()

    text("ODDITY")
    text("Engine", Theme.palette.textDim)

    ui.spacing()
    ui.spacing()

    ui.separator()

    ui.spacing()
    ui.spacing()

    if ui.buttonEx(
        "New Project",
        activeTab == "New",
        SIDEBAR_WIDTH - 24,
        36
    ) then
        activeTab = "New"
        selectedRecent = nil
    end

    ui.spacing()

    if ui.buttonEx(
        "Recent Projects",
        activeTab == "Recent",
        SIDEBAR_WIDTH - 24,
        36
    ) then
        activeTab = "Recent"
        selectedTemplate = nil
        refreshRecent()
    end

    ui.endChild()
end

local function drawTemplateCard(template)
    local isSelected = selectedTemplate == template.id

    if isSelected then
        ui.pushStyleColor(
            "Button",
            Theme.palette.accentActive[1],
            Theme.palette.accentActive[2],
            Theme.palette.accentActive[3],
            Theme.palette.accentActive[4]
        )

        ui.pushStyleColor(
            "ButtonHovered",
            Theme.palette.accentHover[1],
            Theme.palette.accentHover[2],
            Theme.palette.accentHover[3],
            Theme.palette.accentHover[4]
        )

        ui.pushStyleColor(
            "ButtonActive",
            Theme.palette.accent[1],
            Theme.palette.accent[2],
            Theme.palette.accent[3],
            Theme.palette.accent[4]
        )
    else
        ui.pushStyleColor(
            "Button",
            Theme.palette.bgLight[1],
            Theme.palette.bgLight[2],
            Theme.palette.bgLight[3],
            Theme.palette.bgLight[4]
        )

        ui.pushStyleColor(
            "ButtonHovered",
            Theme.palette.bgHover[1],
            Theme.palette.bgHover[2],
            Theme.palette.bgHover[3],
            Theme.palette.bgHover[4]
        )
    end

    local clicked = ui.button(
        template.name .. "\n\n" .. template.blurb,
        CARD_WIDTH,
        CARD_HEIGHT
    )

    if isSelected then
        ui.popStyleColor(3)
    else
        ui.popStyleColor(2)
    end

    if clicked then
        selectedTemplate = template.id
        newProjectName = template.name
        createError = nil
        shouldFocus = true
    end
end

local function drawNewTab(contentWidth)
    ui.spacing()
    ui.spacing()

    text("Create a new project")

    ui.spacing()

    text("Choose a template to get started.", Theme.palette.textDim)

    ui.spacing()
    ui.spacing()

    ui.separator()

    ui.spacing()
    ui.spacing()

    local cols = math.max(
        1,
        math.floor((contentWidth + CARD_GAP) / (CARD_WIDTH + CARD_GAP))
    )

    for i, template in ipairs(Projects.templates) do
        drawTemplateCard(template)

        if i % cols ~= 0 and i ~= #Projects.templates then
            ui.sameLine(nil, CARD_GAP)
        end
    end

    if not selectedTemplate then
        return
    end

    ui.spacing()
    ui.spacing()

    ui.separator()

    ui.spacing()
    ui.spacing()

    text("Project details")

    ui.spacing()


    text("Give your project a name.", Theme.palette.textDim)

    ui.spacing()

    if shouldFocus then
        ui.setKeyboardFocusHere()
    end

    local value, changed = ui.inputText("##ProjectName", newProjectName)

    if changed then
        newProjectName = value
        createError = nil
    end


    shouldFocus = false

    ui.spacing()
    ui.spacing()

    if ui.button("Create Project", 150, 36) then
        local project, err = Projects.create(newProjectName, selectedTemplate)

        if project then
            result = project
        else
            createError = err
        end
    end

    if createError then
        ui.spacing()

        text(createError, {
            0.900,
            0.350,
            0.350,
            1.000
        })
    end
end

local function openProject(project)
    local files, err = Projects.open(project.name)

    if not files then
        return nil, err
    end

    local projectFile = files["project.json"]

    if not projectFile then
        return nil, "Project is missing project.json"
    end

    local path =
        Projects.root ..
        "/" ..
        project.name ..
        "/" ..
        projectFile.name

    local file, readErr = io.open(path, "r")

    if not file then
        return nil, "Failed to open project.json: " .. tostring(readErr)
    end

    local jsonString = file:read("*a")
    file:close()
    
    local buildResult = Build.test(jsonString)

    if not buildResult then
        return nil, "Build.test returned nil"
    end

    return buildResult
end

local function drawRecentTab()
    ui.spacing()
    ui.spacing()

    text("Recent projects")

    ui.spacing()

    text("Continue working on a project.", Theme.palette.textDim)

    ui.spacing()
    ui.spacing()

    ui.separator()

    ui.spacing()
    ui.spacing()

    if not recent then
        refreshRecent()
    end

    if #recent == 0 then
        text(
            "No recent projects.",
            Theme.palette.textDim
        )

        ui.spacing()

        text(
            "Create a new project to get started.",
            Theme.palette.textDim
        )

        return
    end

    for i, project in ipairs(recent) do
        local selected = selectedRecent == i

        if selected then
            ui.pushStyleColor(
                "Header",
                Theme.palette.selection[1],
                Theme.palette.selection[2],
                Theme.palette.selection[3],
                Theme.palette.selection[4]
            )

            ui.pushStyleColor(
                "HeaderHovered",
                Theme.palette.accentActive[1],
                Theme.palette.accentActive[2],
                Theme.palette.accentActive[3],
                Theme.palette.accentActive[4]
            )
        end

        local label = project.name .. "\n" .. timeAgo(project.lastOpened)

        local clicked = ui.selectable(label)

        if selected then
            ui.popStyleColor(2)
        end

        if clicked then
            if selectedRecent == i then
                local opened, err = openProject(project)

                if opened then
                    result = opened
                else
                    createError = err
                end
            else
                selectedRecent = i
                createError = nil
            end
        end

        ui.spacing()
    end

    if selectedRecent then
        ui.separator()

        ui.spacing()
        ui.spacing()

        if ui.button("Open Project", 140, 36) then
            local project = recent[selectedRecent]

            local opened, err = openProject(project)

            if opened then
                result = opened
            else
                createError = err
            end
        end
    end
end

function ProjectSelection.draw()
    local w, h = graphics.getWindowSize()

    ui.setNextWindowPos(0, 0)
    ui.setNextWindowSize(w, h)

    ui.beginWindow(
        "ProjectSelection",
        {
            "NoMove",
            "NoResize",
            "NoCollapse",
            "NoTitleBar"
        }
    )

    drawSidebar()

    ui.sameLine()

    ui.beginChild("Content", 0, 0, false)

    local contentWidth = w - SIDEBAR_WIDTH - CONTENT_PADDING

    if activeTab == "New" then
        drawNewTab(contentWidth)
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