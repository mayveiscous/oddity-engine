local JSON = require "src.core.json"
local debug = require "oddity.debug"
local Details = require "src.data.project_details"

local Build = {}

function Build.test(data)
    local object = JSON.decode(data)

    Details.update(object)

    print(debug.dump(object))

    return object
end

-- needs to build the hierarchy using the json
-- data.scene.objects

return Build