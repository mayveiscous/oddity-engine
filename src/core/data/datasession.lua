local DataSession = {}
DataSession.__index = DataSession

function DataSession.new(store, key, data)
    return setmetatable({
        Store = store,
        Key = tostring(key),
        Data = data,

        Dirty = false,
        Closed = false,
    }, DataSession)
end

function DataSession:MarkDirty()
    if self.Closed then
        return
    end

    self.Dirty = true
end

function DataSession:Save()
    if self.Closed then
        return false
    end

    if not self.Dirty then
        return true
    end

    self.Store:SetAsync(self.Key, self.Data)

    self.Dirty = false

    return true
end

function DataSession:Close(save)
    if self.Closed then
        return
    end

    if save ~= false then
        self:Save()
    end

    self.Closed = true
end

return DataSession