local JSON = require "src.core.json"
local debug = require "oddity.debug"
local Details = require "src.data.project_details"

local Build = {}

function Build.test(data)
    local object = JSON.decode(data)

    Details.update(object)

    for _, obj in ipairs(object.scene.objects) do
        print(obj.name)
    end

    return object
end

return Build