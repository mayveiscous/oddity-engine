local Instance = require("src.core.instance")

local Character = Instance:RegisterClass("Character", "Instance")

Character.PropertyTypes = {
    Controller = "Instance",
    RootPart = "Instance",
}

Character.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent",
    },
    Character = {
        "Controller",
        "RootPart",
    }
}

Character.Defaults = function()
    return {
        Controller = nil,
        RootPart = nil,
    }
end

return Character