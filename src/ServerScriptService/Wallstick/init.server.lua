local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local StarterCharacterScripts = game:GetService("StarterPlayer"):WaitForChild("StarterCharacterScripts")

local function replace(child, parent)
	local found = parent:FindFirstChild(child.Name)
	if found then found:Destroy() end
	child.Parent = parent
end

replace(script:WaitForChild("PlayerScriptsLoader"), StarterPlayerScripts)
--replace(script:WaitForChild("RbxCharacterSounds"), StarterPlayerScripts)
replace(script:WaitForChild("Animate"), StarterCharacterScripts)

local defaultGroup = PhysicsService:GetCollisionGroupName(0)
local characterGroup = "WallstickCharacters"
PhysicsService:CreateCollisionGroup(characterGroup)
PhysicsService:CollisionGroupSetCollidable(defaultGroup, characterGroup, false)

require(script:WaitForChild("Remotes")) -- this creates and runs the remotes we need

local Wallstick = script:WaitForChild("Wallstick")
Wallstick.Parent = ReplicatedStorage