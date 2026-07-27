local BoundingSphere = require "src.physics.rewrite.colliders.bounding_sphere"
local AABB = require "src.physics.rewrite.colliders.aabb"
local Plane = require "src.physics.rewrite.colliders.plane"
local PhysicsObject = require "src.physics.rewrite.core.physics_object"


local Vector3 = require "src.types.vector3"

local debug = require "ignore/lua/debug"


local obj = PhysicsObject.new(Vector3.new(0, 1, 0), Vector3.new(0, 1, 0))

print(debug.dump(obj))

-- abc:Normalize()