local Instance = require "src.core.instance"

local DataStore = require "src.core.data.datastore"
local FilesystemBackend = require "src.core.data.datastore_filesystem"

local DataService = Instance:RegisterClass("DataService", "Service", {
    Properties = {
        ShowInExplorer = {
            type = "boolean",
            default = true,
            category = "Hidden"
        },
    },
})

DataService._stores = {}
DataService._backend = FilesystemBackend.new()

function DataService:GetStore(name)
    if self._stores[name] then
        return self._stores[name]
    end

    local store = DataStore.new(name, self._backend)

    self._stores[name] = store

    return store
end

function DataService:SetBackend(backend)
    assert(type(backend) == "table", "backend must be a table")

    self._backend = backend
    self._stores = {}
end

return DataService