local Debug = {}

Debug.log = require "src.debug.logger"
Debug.inspect = require "src.debug.inspect"
Debug.profile = require "src.debug.profiler"
Debug.watch = require "src.debug.watch"

return Debug