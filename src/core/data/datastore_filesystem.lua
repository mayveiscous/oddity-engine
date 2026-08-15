local JSON = require "src.core.json"
local filesystem = require "oddity.filesystem"
local Projects = require "src.core.projects"

local Backend = {}
Backend.__index = Backend

function Backend.new()
    return setmetatable({
        rootPath = Projects.documentsRoot() .. "/datastores",
    }, Backend)
end

local function sanitize(value)
    value = tostring(value)
    value = value:gsub("[^%w%-%_%.]", "_")

    if value == "" then
        error("invalid datastore name")
    end

    return value
end

function Backend:_getStorePath(storeName)
    return self.rootPath .. "/" .. sanitize(storeName)
end

function Backend:_getDataPath(storeName, key)
    return self:_getStorePath(storeName) .. "/" .. sanitize(key) .. ".json"
end

function Backend:_ensureStore(storeName)
    local path = self:_getStorePath(storeName)

    if not filesystem.exists(path) then
        filesystem.createDirectory(path)
    end
end

function Backend:Get(storeName, key)
    local path = self:_getDataPath(storeName, key)

    if not filesystem.exists(path) then
        return nil
    end

    local file = io.open(path, "r")

    if not file then
        error("failed to open datastore file: " .. path)
    end

    local contents = file:read("*all")
    file:close()

    if contents == "" then
        return nil
    end

    local success, data = pcall(JSON.decode, contents)

    if not success then
        error("failed to decode datastore '" .. storeName .. "/" .. key .. "': " .. tostring(data))
    end

    return data
end

function Backend:Set(storeName, key, value)
    self:_ensureStore(storeName)

    local path = self:_getDataPath(storeName, key)

    local success, encoded = pcall(JSON.encode, value)

    if not success then
        error("failed to encode datastore '" .. storeName .. "/" .. key .. "': " .. tostring(encoded))
    end

    local file = io.open(path, "w")

    if not file then
        error("failed to open datastore file for writing: " .. path)
    end

    file:write(encoded)
    file:close()

    return true
end

function Backend:Update(storeName, key, callback)
    local current = self:Get(storeName, key)

    local success, updated = pcall(callback, current)

    if not success then
        error("UpdateAsync callback failed: " .. tostring(updated))
    end

    if updated == nil then
        return current
    end

    self:Set(storeName, key, updated)

    return updated
end

function Backend:Remove(storeName, key)
    local path = self:_getDataPath(storeName, key)

    if not filesystem.exists(path) then
        return false
    end

    return filesystem.deleteFile(path)
end

function Backend:Has(storeName, key)
    return filesystem.exists(self:_getDataPath(storeName, key))
end

return Backend