package.path = package.path .. ";./?.lua;./src/?.lua;"

-- route prints to the editor ui
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

-- initialize both camera controllers
require("src.core.camera.camera_controller")
require("src.scripting.default_modules.character_camera")

--load services
local runservice = require("src.classes.runservice")
runservice:Init()

require("src.editor.selection")

require("src.game")
require("src.create_character")
require("tests.test")

runservice:Run()