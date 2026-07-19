local classList = {
    "workspace",
    "runservice",
    "block",
    "luascript",
    "tunascript",
    "folder",
    "model",
    "weld",
    "hinge",
    "spring",
    "camera",
    "force",
    "audio",
    "animation",
    "animation_player",
    "character",
    "controller",
    "spawn",
}

local path = "src.classes"

for _, name in ipairs(classList) do
    require(path .. "." .. name)
end