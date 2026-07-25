local Profiler = {}

local timers = {}

function Profiler.start(name)
    timers[name] = os.clock()
end

function Profiler.stop(name)
    local start = timers[name]

    if not start then
        print("Profiler missing:", name)
        return
    end

    local elapsed = os.clock() - start

    print(
        string.format(
            "%s took %.3fms",
            name,
            elapsed * 1000
        )
    )

    timers[name] = nil
end

return Profiler