local Signal = require "oddity.signal"

local Instance = {}
local ClassRegistry = {}

local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

local function generateId()
    return string.gsub(template, "[xy]", function(c)
        local r = math.random(0, 15)
        local v = c == "x" and r or (r % 4) + 8
        return string.format("%x", v)
    end)
end

local function isVector3(v)
    if type(v) ~= "table" then
        return false
    end
    local s = rawget(v, "_state")
    return s ~= nil and s._isVector3 == true
end

local function getPropertyDefinition(classTable, propertyName)
    local class = classTable

    while class do
        if class.Properties then
            local definition = class.Properties[propertyName]

            if definition then
                return definition
            end
        end

        class = class.__ParentClass
    end

    return nil
end

function Instance:RegisterClass(className, parentClassName, definition)
    local base = parentClassName and ClassRegistry[parentClassName] or nil

    local class = setmetatable({}, base and { __index = base } or nil)

    class.__index = class
    class.__ParentClass = base

    definition = definition or {}

    class.Properties = definition.Properties or {}

    if definition.Init then
        class.Init = definition.Init
    end

    ClassRegistry[className] = class

    return class
end

ClassRegistry["Instance"] = Instance
Instance.__index = Instance

Instance.Properties = {
    Name = {
        type = "string",
        category = "Data",
    },

    ClassName = {
        type = "string",
        ReadOnly = true,
        category = "Data",
    },

    Parent = {
        type = "Instance",
        category = "Data",
    },

    UniqueId = {
        type = "string",
        ReadOnly = true,
        category = "Data",
    },

    CanBeDeleted = {
        type = "boolean",
        default = true,
        category = "Hidden",
    },

    CanReparent = {
        type = "boolean",
        default = true,
        category = "Hidden",
    },

    CanRename = {
        type = "boolean",
        default = true,
        category = "Hidden",
    },

    BlockScripts = {
        type = "boolean",
        default = false,
        category = "Hidden",
    },
}

local function setPropertyInternal(instance, propertyName, value)
    local state = rawget(instance, "_state")
    local old = state[propertyName]

    state[propertyName] = value

    if isVector3(value) then
        local Vector3 = require "src.types.vector3"
        Vector3._bind(value, instance, propertyName)
    end

    if old ~= value and state.Changed then
        state.Changed:Fire(propertyName, value)
    end
end

local function buildMeta(classTable)
    return {
        __index = function(t, k)
            local state = rawget(t, "_state")
            local value = state[k]

            if value ~= nil then
                return value
            end

            return classTable[k]
        end,

        __newindex = function(t, k, v)
            local state = rawget(t, "_state")

            if k == "Parent" then
                t:SetParent(v)
                return
            end

            if k == "Name" and state.CanRename == false then
                error(("Instance: %s cannot be renamed!"):format(state.Name), 2)
            end

            local definition = getPropertyDefinition(classTable, k)

            if definition and definition.ReadOnly then
                error(("Property '%s' is read-only!"):format(k), 2)
            end

            if definition and definition.type and v ~= nil then
               local TypeCheck = require "src.core.typecheck"
               local actualType = TypeCheck.typeName(v)

               if actualType ~= definition.type then
                   error(("'%s' expects %s, got %s"):format(k, definition.type, actualType), 2)
                end
            end

            setPropertyInternal(t, k, v)
        end,

        __tostring = function(t)
            local state = rawget(t, "_state")
            return state.Name or state.ClassName or "Instance"
        end,
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
        UniqueId = generateId(),

        _attributes = {},
        Parent = nil,
        _children = {},
        _tags = {},
    }

    state.ChildAdded = Signal.new()
    state.ChildRemoved = Signal.new()
    state.Changed = Signal.new()
    state.AncestryChanged = Signal.new()
    state.AttributeSet = Signal.new()

    local self = setmetatable({}, buildMeta(classTable))
    rawset(self, "_state", state)

    local chain = {}
    local class = classTable

    while class do
        table.insert(chain, 1, class)
        class = class.__ParentClass
    end

    for _, class in ipairs(chain) do
        if class.Properties then
            for propertyName, definition in pairs(class.Properties) do
                if definition.default ~= nil then
                    local state = rawget(self, "_state")

                    local value = definition.default

                    if type(value) == "function" then
                        value = value()
                    end

                    setPropertyInternal(self, propertyName, value)
                end
            end
        end
    end

    if self.Init then
        self:Init()
    end

    return self
end

function Instance:GetProperties()
    local properties = {}
    local class = ClassRegistry[self.ClassName]

    local categories = {}

    while class do
        if class.Properties then
            table.insert(categories, class.Properties)
        end

        class = class.__ParentClass
    end

    for _, propertyDefinitions in ipairs(categories) do
        for propertyName, definition in pairs(propertyDefinitions) do
            local category = definition.category or "Data"

            properties[category] = properties[category] or {}

            properties[category][propertyName] = {
                value = self[propertyName],
                type = definition.type,
                readOnly = definition.ReadOnly == true,
                order = definition.order or 0,
            }
        end
    end

    return properties
end

function Instance:SetParent(newParent)
    local state = rawget(self, "_state")
    local oldParent = state.Parent

    if oldParent == newParent then
        return
    end

    if state.IsCoreService then
        goto skipReparentFlag
    end

    if state.CanReparent ~= nil and state.CanReparent == false then
        return
    end

    ::skipReparentFlag::

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
    if type(name) ~= "string" then
        error("Attribute names must be a string", 2)
    end

    local state = rawget(self, "_state")
    state._attributes[name] = value
    state.AttributeSet:Fire(name, value)
end

function Instance:GetChildren()
    local state = rawget(self, "_state")
    local list = {}
    for child in pairs(state._children) do
        table.insert(list, child)
    end
    return list
end

function Instance:GetDescendants()
    local descendants = {}

    local function recurse(instance)
        local state = rawget(instance, "_state")
        assert(state, ("Expected Instance, got %s"):format(tostring(instance)))

        for child in pairs(state._children) do
            table.insert(descendants, child)
            recurse(child)
        end
    end

    recurse(self)

    return descendants
end

function Instance:GetAncestors()
    local ancestors = {}

    local current = self.Parent

    while current do
        table.insert(ancestors, current)
        current = current.Parent
    end

    return ancestors
end

function Instance:IsDescendantOf(inst)
    local current = self.Parent
    if current == inst then return true end

    while current do
        if current == inst then return true end
        current = current.Parent
    end
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

function Instance:OnPropertyChanged(propName)
    local filtered = Signal.new()

    self.Changed:Connect(function(k, v)
        if k == propName then filtered:Fire(v) end
    end)

    return filtered
end

function Instance:AddTag(tag)
    local state = rawget(self, "_state")
    if not state._tags[tag] then
        state._tags[tag] = tag
    end
end

function Instance:DeleteTag(tag)
    local state = rawget(self, "_state")

    if tag == "COREcantDelete" then
        return
    end

    if state._tags[tag] then
        state._tags[tag] = nil
    end
end

function Instance:Destroy()
    local state = rawget(self, "_state")
    if state.CanBeDeleted ~= nil and state.CanBeDeleted == false then
        return
    end

    if state._tags["COREcantDelete"] then
        return
    end

    self:SetParent(nil)
    for _, child in ipairs(self:GetChildren()) do
        child:Destroy()
    end
end

function Instance:ScriptsBlocked()
    if self.BlockScripts then
        return true 
    end

    local parent = self.Parent
    local blocked = false

    while parent do
        if parent.BlockScripts then
            blocked = true
        end

        parent = parent.Parent
    end

    return blocked
end

return Instance