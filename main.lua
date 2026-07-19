package.path = package.path .. ";./?.lua;./src/?.lua;"

require("src.classes")

local runservice = require("src.classes.runservice")
runservice:Init()

require("src.core.camera_controller")
require("src.create_character")
require("tests.test")

runservice:Run()