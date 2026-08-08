local filesystem = require "filesystem"

local function loadDirectory(directory, modulePath)
    for _, entry in ipairs(filesystem.listDirectory(directory)) do
        if entry.directory then
            loadDirectory(directory .. "/" .. entry.name, modulePath .. "." .. entry.name)
        elseif entry.name:sub(-4) == ".lua" then
            local name = entry.name:sub(1, -5)
            require(modulePath .. "." .. name)
        end
    end
end

loadDirectory("src/classes", "src.classes")