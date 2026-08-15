local DataSession = require "src.core.data.datasession"

local DataStore = {}
DataStore.__index = DataStore

function DataStore.new(name, backend)
    return setmetatable({
        Name = name,
        Backend = backend,
    }, DataStore)
end

function DataStore:GetAsync(key)
    assert(key ~= nil, "DataStore key is required")

    return self.Backend:Get(self.Name, tostring(key))
end

function DataStore:SetAsync(key, value)
    assert(key ~= nil, "DataStore key is required")

    return self.Backend:Set(self.Name, tostring(key), value)
end

function DataStore:UpdateAsync(key, callback)
    assert(key ~= nil, "DataStore key is required")
    assert(type(callback) == "function", "UpdateAsync callback must be a function")

    return self.Backend:Update(self.Name, tostring(key), callback)
end

function DataStore:RemoveAsync(key)
    assert(key ~= nil, "DataStore key is required")

    return self.Backend:Remove(self.Name, tostring(key))
end

function DataStore:HasAsync(key)
    assert(key ~= nil, "DataStore key is required")

    return self.Backend:Has(self.Name, tostring(key))
end

function DataStore:OpenSession(key, defaultData)
    key = tostring(key)

    local data = self:GetAsync(key)

    if data == nil then
        data = defaultData or {}
    end

    return DataSession.new(self, key, data)
end

return DataStore