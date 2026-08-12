local BoundingSphere = require "src.physics.colliders.bounding_sphere"
local AABB = require "src.physics.colliders.aabb"
local Plane = require "src.physics.colliders.plane"
local PhysicsObject = require "src.physics.core.physics_object"


local Vector3 = require "src.types.vector3"

local debug = require "oddity.debug"


local obj = PhysicsObject.new(Vector3.new(0, 1, 0), Vector3.new(0, 1, 0))

-- abc:Normalize()