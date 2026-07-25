local major = 0
local minor = 1
local patch = 0

local vs = ("v%s.%s.%s"):format(tostring(major), tostring(minor), tostring(patch))

local meta = {
  major = major,
  minor = minor,
  patch = patch,
}

return { meta = meta, version = vs }