local classList = {
    "workspace",
    "runservice",
    "inputservice",
    "selectionservice",
    "lighting",
    "players",

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
    "point_light",
    "sky",
    "spawn",
    "spot_light",
    "spring",
    "tunascript",
    "weld",
}

local path = "src.classes"

for _, name in ipairs(classList) do
    require(path .. "." .. name)
end