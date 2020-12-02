local PhysicsService = game:GetService("PhysicsService")

WORLD_CENTER = CFrame.new(10000, 0, 0)
COLLIDER_SIZE2 = Vector3.new(32, 32, 32)
PHYSICS_ID = PhysicsService:GetCollisionGroupId("WallstickCharacters")

DEBUG = false
DEBUG_TRANSPARENCY = DEBUG and 0 or 1

DEFAULT_CAMERA_MODE = DEBUG and "Debug" or "Custom"
CUSTOM_CAMERA_SPIN = true -- if in custom camera match the part spin

IGNORE_CLASS_PART = {
	["Terrain"] = true,
	["SpawnLocation"] = true,
	["Seat"] = true,
	["VehicleSeat"] = true
}

local env = getfenv()
env.script = nil
return env