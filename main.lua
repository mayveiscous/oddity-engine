package.path = package.path .. ";./?.lua;./src/?.lua;"

-- route prints to the editor ui
local Log = require "src.editor.state.log"
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

require "src.classes"

-- initialize both camera controllers
require "src.core.camera.camera_controller"
require "src.scripting.default_modules.character_camera"

--load services
local runservice = require "src.classes.services.runservice"
runservice:Init()

require "src.editor.state.selection"

require "src.create-runtime.baseplate"
require "src.game"

-- the . in the folder names mess up require path resolving :/
-- dofile("./.ignore/.tests/test.lua")

runservice:Run()