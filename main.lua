package.path = package.path .. ";./?.lua;./src/?.lua;"

local task = require("task")
require("src.classes") -- load all classes
require("test")