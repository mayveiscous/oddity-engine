local Instance = require "src.core.instance"

local Vector3 = require "src.types.vector3"
local Color3 = require "src.types.color3"

local Lighting = Instance:RegisterClass("Lighting", "Instance", {
    Properties = {
        Direction = {
            type = "Vector3",
            default = function()
                return Vector3.new(-0.5, -1.0, -0.3)
            end,
            category = "Lighting",
        },

        Sky = {
            type = "Instance",
            default = nil,
            category = "Lighting",
        },

        Color = {
            type = "Color3",
            default = function()
                return Color3.new(1, 1, 1)
            end,
            category = "Lighting",
        },

        AmbientColor = {
            type = "Color3",
            default = function()
                return Color3.new(1, 1, 1)
            end,
            category = "Lighting",
        },

        AmbientIntensity = {
            type = "number",
            default = 0.15,
            category = "Lighting",
        },

        FogDensity = {
            type = "number",
            default = 0.0008,
            category = "Lighting",
        },
        
        CanBeDeleted = {
            type = "boolean",
            default = false,
            category = "Hidden"
        },

        CanRename = {
            type = "boolean",
            default = false,
            category = "Hidden",
        },

        CanReparent = {
            type = "boolean",
            default = false,
            category = "Hidden"
        },

        IsCoreService = {
            type = "boolean",
            default = true,
            category = "Hidden",
        },
    },
})

return Lighting