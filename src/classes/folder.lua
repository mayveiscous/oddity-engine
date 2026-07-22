local Instance = require("src.core.instance")

local Folder = Instance:RegisterClass("Folder", "Instance")

Folder.Properties = {
    Data = {
        "Name",
        "ClassName",
        "Parent",
    },
}

return Folder