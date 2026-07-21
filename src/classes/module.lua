local Instance = require("src.core.instance")

local Module = Instance:RegisterClass("Module", "Instance")

Module.Defaults = function()
    return {
        Source = "",
    }
end

return Module