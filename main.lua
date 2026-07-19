package.path = package.path .. ";./?.lua;./src/?.lua;"

require("src.classes")

local runservice = require("src.classes.runservice")
runservice:Init()

require("src.core.camera_controller")
require("src.populate_game")
require("test")

runservice:Run()