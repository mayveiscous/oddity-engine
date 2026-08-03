local Vector3 = require "src.types.vector3"
local Instance = require "src.core.instance"

local animations = {
Walk = {
    Looped = true,
    Length = 1.20,

    Tracks = {
        LeftLeg = {
            { time = 0.00, rotation = Vector3.new(-38, 0,  5) }, -- contact
            { time = 0.15, rotation = Vector3.new(-22, 0,  3) },
            { time = 0.32, rotation = Vector3.new(  8, 0,  0) }, -- passing
            { time = 0.50, rotation = Vector3.new( 36, 0, -5) }, -- forward
            { time = 0.68, rotation = Vector3.new( 18, 0, -2) },
            { time = 0.85, rotation = Vector3.new(-12, 0,  2) },
            { time = 1.05, rotation = Vector3.new(-38, 0,  5) },
            { time = 1.20, rotation = Vector3.new(-38, 0,  5) },
        },

        RightLeg = {
            { time = 0.00, rotation = Vector3.new( 36, 0, -5) },
            { time = 0.15, rotation = Vector3.new( 18, 0, -2) },
            { time = 0.32, rotation = Vector3.new(-12, 0,  2) },
            { time = 0.50, rotation = Vector3.new(-38, 0,  5) },
            { time = 0.68, rotation = Vector3.new(-22, 0,  3) },
            { time = 0.85, rotation = Vector3.new(  8, 0,  0) },
            { time = 1.05, rotation = Vector3.new( 36, 0, -5) },
            { time = 1.20, rotation = Vector3.new( 36, 0, -5) },
        },

        LeftArm = {
            { time = 0.00, rotation = Vector3.new( 32, 0, 0) },
            { time = 0.15, rotation = Vector3.new( 18, 0, 0) },
            { time = 0.32, rotation = Vector3.new( -2, 0, 0) },
            { time = 0.50, rotation = Vector3.new(-30, 0, 0) },
            { time = 0.68, rotation = Vector3.new(-18, 0, 0) },
            { time = 0.85, rotation = Vector3.new(  4, 0, 0) },
            { time = 1.05, rotation = Vector3.new( 32, 0, 0) },
            { time = 1.20, rotation = Vector3.new( 32, 0, 0) },
        },

        RightArm = {
            { time = 0.00, rotation = Vector3.new(-30, 0, 0) },
            { time = 0.15, rotation = Vector3.new(-18, 0, 0) },
            { time = 0.32, rotation = Vector3.new(  4, 0, 0) },
            { time = 0.50, rotation = Vector3.new( 32, 0, 0) },
            { time = 0.68, rotation = Vector3.new( 18, 0, 0) },
            { time = 0.85, rotation = Vector3.new( -2, 0, 0) },
            { time = 1.05, rotation = Vector3.new(-30, 0, 0) },
            { time = 1.20, rotation = Vector3.new(-30, 0, 0) },
        },

        Body = {
            { time = 0.00, rotation = Vector3.new( 3, 0, -5) },
            { time = 0.15, rotation = Vector3.new( 1, 0, -2) },
            { time = 0.32, rotation = Vector3.new(-2, 0,  2) },
            { time = 0.50, rotation = Vector3.new(-3, 0,  5) },
            { time = 0.68, rotation = Vector3.new(-1, 0,  2) },
            { time = 0.85, rotation = Vector3.new( 2, 0, -2) },
            { time = 1.05, rotation = Vector3.new( 3, 0, -5) },
            { time = 1.20, rotation = Vector3.new( 3, 0, -5) },
        },
    },
},

    Jump = {
        Looped = false,
        Length = 1,

        Tracks = {
            LeftLeg = {
                { time = 0.00, rotation = Vector3.new(  0, 0, 0) },
                { time = 0.15, rotation = Vector3.new( 18, 0, 0) }, -- crouch
                { time = 0.30, rotation = Vector3.new(-28, 0, 0) }, -- push off
                { time = 0.60, rotation = Vector3.new(-12, 0, 0) }, -- apex
                { time = 0.85, rotation = Vector3.new( 20, 0, 0) }, -- landing
                { time = 1.00, rotation = Vector3.new(  0, 0, 0) },
            },

            RightLeg = {
                { time = 0.00, rotation = Vector3.new(  0, 0, 0) },
                { time = 0.15, rotation = Vector3.new( 18, 0, 0) },
                { time = 0.30, rotation = Vector3.new(-28, 0, 0) },
                { time = 0.60, rotation = Vector3.new(-12, 0, 0) },
                { time = 0.85, rotation = Vector3.new( 20, 0, 0) },
                { time = 1.00, rotation = Vector3.new(  0, 0, 0) },
            },

            LeftArm = {
                { time = 0.00, rotation = Vector3.new(  0, 0, 0) },
                { time = 0.15, rotation = Vector3.new(-18, 0, 0) },
                { time = 0.30, rotation = Vector3.new( 55, 0, 0) }, -- arms swing up
                { time = 0.60, rotation = Vector3.new( 42, 0, 0) },
                { time = 0.85, rotation = Vector3.new( 12, 0, 0) },
                { time = 1.00, rotation = Vector3.new(  0, 0, 0) },
            },

            RightArm = {
                { time = 0.00, rotation = Vector3.new(  0, 0, 0) },
                { time = 0.15, rotation = Vector3.new(-18, 0, 0) },
                { time = 0.30, rotation = Vector3.new( 55, 0, 0) },
                { time = 0.60, rotation = Vector3.new( 42, 0, 0) },
                { time = 0.85, rotation = Vector3.new( 12, 0, 0) },
                { time = 1.00, rotation = Vector3.new(  0, 0, 0) },
            },

            Torso = {
                { time = 0.00, rotation = Vector3.new( 0, 0, 0) },
                { time = 0.15, rotation = Vector3.new(10, 0, 0) }, -- lean forward
                { time = 0.30, rotation = Vector3.new(-8, 0, 0) }, -- extend
                { time = 0.60, rotation = Vector3.new(-4, 0, 0) },
                { time = 0.85, rotation = Vector3.new( 8, 0, 0) }, -- absorb landing
                { time = 1.00, rotation = Vector3.new( 0, 0, 0) },
            },
        },
    },
}

local animGet = {}

function animGet.Get(name)
    local animation = Instance.new("Animation")
    local data = animations[name]

    animation.Length = data.Length
    animation.Looped = data.Looped
    animation.Tracks = data.Tracks

    return animation
end

return animGet