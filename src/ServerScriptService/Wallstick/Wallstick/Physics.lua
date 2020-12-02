-- CONSTANTS

local R15 = {
	["Part"] = true,
	["MeshPart"] = true,
	["Motor6D"] = true,
	["Humanoid"] = true,
}

local R6 = {
	["Head"] = true,
	["HumanoidRootPart"] = true,
	["Humanoid"] = true,
}

local CONSTANTS = require(script.Parent:WaitForChild("Constants"))

local ZERO3 = Vector3.new(0, 0, 0)
local UNIT_X = Vector3.new(1, 0, 0)
local UNIT_Y = Vector3.new(0, 1, 0)

-- Class

local PhysicsClass = {}
PhysicsClass.__index = PhysicsClass
PhysicsClass.ClassName = "Physics"

function PhysicsClass.new(player)
	local self = setmetatable({}, PhysicsClass)

	self.World = Instance.new("Model")
	self.World.Name = "PhysicsWorld"
	self.World.Parent = workspace

	self.Collision = Instance.new("Model")
	self.Collision.Name = "PhysicsCollision"
	self.Collision.Parent = self.World

	self.Floor = nil
	
	self.Character = stripCopyCharacter(player.Character)
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.HRP = self.Humanoid.RootPart
	
	self.Character.Parent = self.World

	return self
end

-- Private Methods

local function getRotationBetween(u, v, axis)
	local dot, uxv = u:Dot(v), u:Cross(v)
	if dot < -0.99999 then return CFrame.fromAxisAngle(axis, math.pi) end
	return CFrame.new(0, 0, 0, uxv.x, uxv.y, uxv.z, 1 + dot)
end

function stripCopyCharacter(character)
	local clone = nil
	local archivable = character.Archivable

	character.Archivable = true
	clone = character:Clone()
	character.Archivable = archivable

	local realHumanoid = character:WaitForChild("Humanoid")
	local isR15 = (realHumanoid.RigType == Enum.HumanoidRigType.R15)
	local validClasses = isR15 and R15 or R6

	for _, part in pairs(clone:GetDescendants()) do
		if not validClasses[part.ClassName] then
			part:Destroy()
		elseif part:IsA("BasePart") then
			part.Transparency = CONSTANTS.DEBUG_TRANSPARENCY
		end
	end

	local humanoid = clone:WaitForChild("Humanoid")
	
	humanoid:ClearAllChildren()
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

	return clone
end
 
-- Public Methods

function PhysicsClass:MatchHumanoid(humanoid)
	self.Humanoid.WalkSpeed = humanoid.WalkSpeed
	self.Humanoid.JumpPower = humanoid.JumpPower
	self.Humanoid.Jump = humanoid.Jump
end

function PhysicsClass:UpdateFloor(prevPart, newPart, prevNormal, newNormal)
	if self.Floor then
		self.Floor:Destroy()
		self.Floor = nil
	end

	local floor = nil
	if CONSTANTS.IGNORE_CLASS_PART[newPart.ClassName] then
		local isTerrain = newPart:IsA("Terrain")
		floor = Instance.new("Part")
		floor.CanCollide = not isTerrain and newPart.CanCollide or false
		floor.Size = not isTerrain and newPart.Size or ZERO3
	else
		floor = newPart:Clone()
		floor:ClearAllChildren()
	end

	floor.Name = "PhysicsFloor"
	floor.Transparency = CONSTANTS.DEBUG_TRANSPARENCY
	floor.Anchored = true
	floor.Velocity = ZERO3
	floor.RotVelocity = ZERO3
	floor.CFrame = CONSTANTS.WORLD_CENTER * getRotationBetween(newNormal, UNIT_Y, UNIT_X)
	floor.Parent = self.World

	self.Floor = floor
end

function PhysicsClass:Destroy()
	self.World:Destroy()
end

--

return PhysicsClass