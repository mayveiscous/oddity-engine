local classList = {
    "part",
    "script"
}

local path = "src.classes"

for _, name in ipairs(classList) do
    require(path .. "." .. name)
end