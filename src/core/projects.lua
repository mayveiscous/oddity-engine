local filesystem = require "oddity.filesystem"

local Projects = {}

local function documentsRoot()
    local home = os.getenv("USERPROFILE") or os.getenv("HOME")
    if not home then
        error("Could not resolve a home directory (no USERPROFILE or HOME env var)")
    end
    return home .. "/Documents/Oddity/Projects"
end

Projects.root = documentsRoot()

local function ensureRoot()
    if not filesystem.exists(Projects.root) then
        filesystem.createDirectory(Projects.root)
    end
end

Projects.templates = {
    {id = "baseplate", name = "Baseplate", blurb = "A flat plate to start building on."},
    {id = "empty", name = "Empty", blurb = "A completely empty project."},
}

function Projects.listRecent()
    ensureRoot()

    local results = {}

    for _, entry in ipairs(filesystem.listDirectory(Projects.root)) do
        if entry.directory then
            local path = Projects.root .. "/" .. entry.name
            local ok, modified = pcall(filesystem.lastWriteTime, path)

            table.insert(results, {
                name = entry.name,
                path = path,
                lastOpened = ok and modified or 0,
            })
        end
    end

    table.sort(results, function(a, b) return a.lastOpened > b.lastOpened end)

    return results
end

local function sanitizeName(name)
    return (name:gsub("[^%w%s%-_]", ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

function Projects.create(name, templateId)
    ensureRoot()

    local clean = sanitizeName(name or "")
    if clean == "" then
        return nil, "Project name can't be empty"
    end

    local path = Projects.root .. "/" .. clean
    if filesystem.exists(path) then
        return nil, "A project named \"" .. clean .. "\" already exists"
    end

    filesystem.createDirectory(path)

    return {name = clean, path = path, lastOpened = os.time()}
end

return Projects