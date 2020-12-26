local PhysicsService = game:GetService("PhysicsService")

local CONSTANTS = {}

CONSTANTS.WORLD_CENTER = CFrame.new(10000, 0, 0)
CONSTANTS.COLLIDER_SIZE2 = Vector3.new(32, 32, 32)
CONSTANTS.PHYSICS_ID = PhysicsService:GetCollisionGroupId("WallstickCharacters")

CONSTANTS.REPLICATE_RATE = 0.1 -- send an update every x seconds

CONSTANTS.DEBUG = false
CONSTANTS.DEBUG_TRANSPARENCY = CONSTANTS.DEBUG and 0 or 1

CONSTANTS.DEFAULT_CAMERA_MODE = CONSTANTS.DEBUG and "Debug" or "Custom"
CONSTANTS.CUSTOM_CAMERA_SPIN = true -- if in custom camera match the part spin
CONSTANTS.MAINTAIN_WORLD_VELOCITY = true -- maintains world space velocity when using the :Set() method 

CONSTANTS.IGNORE_CLASS_PART = {
	["Terrain"] = true,
	["SpawnLocation"] = true,
	["Seat"] = true,
	["VehicleSeat"] = true
}

CONSTANTS.IGNORE_STATES = {
	[Enum.HumanoidStateType.None] = true,
	[Enum.HumanoidStateType.Dead] = true,
}

return CONSTANTS