local Signal = {}
Signal.__index = Signal

local task = require "oddity.task"

function Signal.new()
    return setmetatable({
        _connections = {},
        _nextId = 1
    }, Signal)
end

function Signal:Connect(fn)
    local id = self._nextId
    self._nextId = id + 1

    self._connections[id] = fn

    local connection = {
        Connected = true
    }

    function connection:Disconnect()
        self.Connected = false
        Signal._connections_remove(self)
    end

    connection._id = id
    connection._signal = self

    return connection
end

function Signal._connections_remove(connection)
    local signal = connection._signal
    signal._connections[connection._id] = nil
end

function Signal:Fire(...)
    for _, fn in pairs(self._connections) do
        task.spawn(fn, ...)
    end
end

function Signal:Wait()
    local co = coroutine.running()
    local args
    local conn
    conn = self:Connect(function(...)
        args = {...}
        conn:Disconnect()
        coroutine.resume(co)
    end)
    coroutine.yield()
    return table.unpack(args)
end

return Signal