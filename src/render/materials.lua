local Materials = {
    Plastic = { specularStrength = 0.5,  shininess = 32  },
    Metal   = { specularStrength = 0.9,  shininess = 128 },
    Wood    = { specularStrength = 0.1,  shininess = 8   },
    Fabric  = { specularStrength = 0.05, shininess = 4   },
    Glass   = { specularStrength = 0.95, shininess = 256 },
}

Materials.Default = Materials.Plastic

function Materials.Get(name)
    return Materials[name] or Materials.Default
end

return Materials