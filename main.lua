package.path = package.path .. ";./?.lua;./src/?.lua;"

require("src.classes")

local runservice = require("src.classes.runservice")
runservice:Init()

-- require("src.core.camera.camera_controller")
require("src.game")
require("src.create_character")
require("src.core.camera.character_camera")
require("tests.test")

runservice:Run()