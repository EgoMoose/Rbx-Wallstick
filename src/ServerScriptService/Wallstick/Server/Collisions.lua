local PhysicsService = game:GetService("PhysicsService")

local defaultGroup = PhysicsService:GetCollisionGroupName(0)
local characterGroup = "WallstickCharacters"

PhysicsService:CreateCollisionGroup(characterGroup)
PhysicsService:CollisionGroupSetCollidable(defaultGroup, characterGroup, false)

return true