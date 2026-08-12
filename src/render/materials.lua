-- `image` is a key into the shared image registry (Enum.Images). When present,
-- the material's PNG is sampled and tinted by the object's Color (multiplied),
-- unlike a Texture instance, which fully overrides Color. `image` is optional.
-- Materials without one just render as flat, lit Color.
local Materials = {
    Plastic  = { specularStrength = 0.5,  shininess = 32,  image = nil        },
    Metal    = { specularStrength = 0.9,  shininess = 128, image = "metal"    },
    Wood     = { specularStrength = 0.1,  shininess = 8,   image = "wood"     },
    Fabric   = { specularStrength = 0.05, shininess = 4,   image = "fabric"   },
    Glass    = { specularStrength = 0.95, shininess = 256, image = "glass"    },
    Brick    = { specularStrength = 0.2,  shininess = 8,   image = "brick"    },
    Grass    = { specularStrength = 0.05, shininess = 4,   image = "grass"    },
    Concrete = { specularStrength = 0.15, shininess = 16,  image = "concrete" },
}

Materials.Default = Materials.Plastic

function Materials.Get(name)
    return Materials[name] or Materials.Default
end

return Materials