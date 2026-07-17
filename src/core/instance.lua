local Signal = require("src.core.signal")

local Instance = {}
local ClassRegistry = {}

function Instance:RegisterClass(className, parentClassName)
    local base = parentClassName and ClassRegistry[parentClassName] or nil
    local class = setmetatable({}, base and { __index = base } or nil)
    class.__index = class
    class.__ParentClass = base
    ClassRegistry[className] = class
    return class
end

-- base "Instance" class itself
-- so Instance.new("Instance") is valid
ClassRegistry["Instance"] = Instance
Instance.__index = Instance

local function isVector3(v)
    if type(v) ~= "table" then
        return false
    end
    local s = rawget(v, "_state")
    return s ~= nil and s._isVector3 == true
end

local function buildMeta(classTable)
    return {
        __index = function(t, k)
            local state = rawget(t, "_state")
            local v = state[k]
            if v ~= nil then
                return v
            end
            return classTable[k]
        end,

        __newindex = function(t, k, v)
            local state = rawget(t, "_state")

            if k == "Parent" then
                t:SetParent(v)
                return
            end

            local old = state[k]
            state[k] = v

            if isVector3(v) then
                local Vector3 = require("src.types.vector3")
                Vector3._bind(v, t, k)
            end

            if old ~= v and state.Changed then
                state.Changed:Fire(k, v)
            end
        end
    }
end

function Instance.new(className)
    local classTable = ClassRegistry[className]
    if not classTable then
        error(("Unknown class '%s'"):format(className))
    end

    local state = {
        ClassName = className,
        Name = className,
        _attributes = {},
        Parent = nil,
        _children = {},
    }
    state.ChildAdded = Signal.new()
    state.ChildRemoved = Signal.new()
    state.Changed = Signal.new()
    state.AncestryChanged = Signal.new()
    state.AttributeSet = Signal.new()

    local self = setmetatable({}, buildMeta(classTable))
    rawset(self, "_state", state)

    local chain = {}
    local c = classTable
    while c do
        table.insert(chain, 1, c)
        c = c.__ParentClass
    end
    for _, class in ipairs(chain) do
        if class.Defaults then
            local defaults = type(class.Defaults) == "function" and class.Defaults() or class.Defaults
            for k, v in pairs(defaults) do
                self[k] = v
            end
        end
    end

    if self.Init then
        self:Init()
    end

    return self
end

function Instance:SetParent(newParent)
    local state = rawget(self, "_state")
    local oldParent = state.Parent

    if oldParent == newParent then
        return
    end

    if oldParent then
        local oldState = rawget(oldParent, "_state")
        oldState._children[self] = nil
        oldState.ChildRemoved:Fire(self)
    end

    state.Parent = newParent

    if newParent then
        local newState = rawget(newParent, "_state")
        newState._children[self] = true
        newState.ChildAdded:Fire(self)
    end

    state.AncestryChanged:Fire(self, newParent)
end

function Instance:GetAttributes()
    local state = rawget(self, "_state")
    local list = {}
    for name, value in pairs(state._attributes) do
        list[name] = value
    end
    return list
end

function Instance:GetAttribute(name)
    local state = rawget(self, "_state")
    return state._attributes[name]
end

function Instance:SetAttribute(name, value)
    local state = rawget(self, "_state")
    state._attributes[name] = value
end


function Instance:GetChildren()
    local state = rawget(self, "_state")
    local list = {}
    for child in pairs(state._children) do
        table.insert(list, child)
    end
    return list
end

function Instance:FindFirstChild(name)
    local state = rawget(self, "_state")
    for child in pairs(state._children) do
        if child.Name == name then
            return child
        end
    end
    return nil
end

function Instance:IsA(className)
    local target = ClassRegistry[className]
    local class = ClassRegistry[self.ClassName]
    while class do
        if class == target then
            return true
        end
        class = class.__ParentClass
    end
    return false
end

function Instance:OnExactChange(propName)
    local filtered = Signal.new()

    self.Changed:Connect(function(k, v)
        if k == propName then filtered:Fire(v) end
    end)

    return filtered
end

function Instance:Destroy()
    self:SetParent(nil)
    for _, child in ipairs(self:GetChildren()) do
        child:Destroy()
    end
end

return Instance