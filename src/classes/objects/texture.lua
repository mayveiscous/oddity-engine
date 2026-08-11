local Instance = require "src.core.instance"

-- A Texture is parented under a Block (or any textured object) and fully
-- overrides that face's Color with an image, rather than tinting it. Compare
-- to Material, which tints its image by Color instead of overriding it.
--
-- Face selects which side of the parent's mesh this applies to. "All" applies
-- to every face. Face is only meaningful on axis-aligned shapes (Block) - on
-- Wedge only some faces exist, and on Sphere there are no discrete faces at
-- all, so non-"All" values there will have inconsistent/partial results.
local Texture = Instance:RegisterClass("Texture", "Instance", {
    Properties = {
        Image = {
            type = "string",
            default = "",
            category = "Appearance",
        },

        Face = {
            type = "string",
            default = "All",
            category = "Appearance",
        },
    },
})

Texture.FaceOrder = { "Front", "Back", "Left", "Right", "Top", "Bottom" }

Texture.FaceIndex = {
    Front = 1,
    Back = 2,
    Left = 3,
    Right = 4,
    Top = 5,
    Bottom = 6,
}

return Texture
