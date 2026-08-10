local details = require "src.data.project_details"

local Tabs = {}

local tabs = {
    {
        name = details.ProjectName,
        type = "scene",
    }
}

local activeTab = 1

local scriptContents = {}

function Tabs.list()
    return tabs
end

function Tabs.getActiveIndex()
    return activeTab
end

function Tabs.setActiveIndex(i)
    if #tabs == 0 then
        activeTab = 0
        return
    end

    if i == nil then
        activeTab = 1
        return
    end

    if i < 1 then
        i = 1
    elseif i > #tabs then
        i = #tabs
    end

    activeTab = i
end

function Tabs.getActive()
    if #tabs == 0 then
        return nil
    end

    if activeTab < 1 then
        activeTab = 1
    elseif activeTab > #tabs then
        activeTab = #tabs
    end

    return tabs[activeTab]
end

function Tabs.getSceneIndex()
    for i, tab in ipairs(tabs) do
        if tab.type == "scene" then
            return i
        end
    end
    return 1
end

function Tabs.openScript(script)
    for i, tab in ipairs(tabs) do
        if tab.type == "script" and tab.script == script then
            activeTab = i
            return
        end
    end

    table.insert(tabs, {
        name = script.Name,
        type = "script",
        script = script,
    })

    scriptContents[script] = script.Source or ""

    activeTab = #tabs
end

function Tabs.closeScript(script)
    for i, tab in ipairs(tabs) do
        if tab.type == "script" and tab.script == script then
            scriptContents[script] = nil
            table.remove(tabs, i)

            if activeTab > #tabs then
                activeTab = #tabs
            elseif activeTab < 1 then
                activeTab = 1
            end

            return
        end
    end
end

function Tabs.updateScript(script)
    for _, tab in ipairs(tabs) do
        if tab.type == "script" and tab.script == script then
            tab.name = script.Name
            return
        end
    end
end

function Tabs.getScriptContent(script)
    return scriptContents[script] or ""
end

function Tabs.setScriptContent(script, content)
    scriptContents[script] = content
end

function Tabs.discardPendingEdits()
    for script, _ in pairs(scriptContents) do
        scriptContents[script] = script.Source or ""
    end
end

return Tabs