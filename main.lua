package.path = package.path .. ";./?.lua;./src/?.lua;"

local Log = require("src.editor.log")
local _originalPrint = print

function print(...)
    _originalPrint(...)
    local args = {...}
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(args[i])
    end
    Log.info(table.concat(parts, "\t"))
end

require("src.classes")

require("src.core.camera.camera_controller")
require("src.scripting.default_modules.character_camera")

local runservice = require("src.classes.runservice")
runservice:Init()

--require("src.core.camera.camera_controller")
require("src.game")
require("src.create_character")
require("src.scripting.default_modules.character_camera")
require("tests.test")

runservice:Run()