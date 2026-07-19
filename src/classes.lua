local classList = {
    "workspace",
    "runservice",

    "animation",
    "animation_player",
    "audio",
    "block",
    "camera",
    "character",
    "controller",
    "folder",
    "force",
    "hinge",
    "luascript",
    "model",
    "motor",
    "player",
    "spawn",
    "spring",
    "tunascript",
    "weld",
}

local path = "src.classes"

for _, name in ipairs(classList) do
    require(path .. "." .. name)
end