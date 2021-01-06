-- CONSTANTS

local STRIP = {
	["Part"] = true,
	["MeshPart"] = true,
	["Motor6D"] = true,
	["Humanoid"] = true,
}

local CONSTANTS = require(script.Parent:WaitForChild("Constants"))

local ZERO3 = Vector3.new(0, 0, 0)
local UNIT_X = Vector3.new(1, 0, 0)
local UNIT_Y = Vector3.new(0, 1, 0)
local VEC_XZ = Vector3.new(1, 0, 1)

-- Class

local PhysicsClass = {}
PhysicsClass.__index = PhysicsClass
PhysicsClass.ClassName = "Physics"

function PhysicsClass.new(wallstick)
	local self = setmetatable({}, PhysicsClass)

	self.Wallstick = wallstick

	self.World = Instance.new("Model")
	self.World.Name = "PhysicsWorld"
	self.World.Parent = workspace.CurrentCamera

	self.Collision = Instance.new("Model")
	self.Collision.Name = "PhysicsCollision"
	self.Collision.Parent = self.World

	self.Floor = nil
	self._floorResized = nil
	
	self.Character = stripCopyCharacter(wallstick.Player.Character)
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.HRP = self.Humanoid.RootPart
	
	self.Gyro = Instance.new("BodyGyro")
	self.Gyro.D = 0
	self.Gyro.MaxTorque = Vector3.new(100000, 100000, 100000)
	self.Gyro.P = 25000

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

	for _, part in pairs(clone:GetDescendants()) do
		if not STRIP[part.ClassName] then
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

function PhysicsClass:UpdateGyro()
	local cameraCF = workspace.CurrentCamera.CFrame
	local isRelative = self.Wallstick._camera.CameraModule:IsCamRelative()

	local physicsHRPCF = self.Wallstick.Physics.HRP.CFrame
	local physicsCameraCF = physicsHRPCF * self.Wallstick.HRP.CFrame:ToObjectSpace(cameraCF)

	self.Gyro.CFrame = CFrame.lookAt(physicsHRPCF.p, physicsHRPCF.p + physicsCameraCF.LookVector * VEC_XZ)
	self.Gyro.Parent = isRelative and self.Wallstick.Physics.HRP or nil
	
	if isRelative then
		self.Humanoid.AutoRotate = false
	else
		self.Humanoid.AutoRotate = self.Wallstick.Humanoid.AutoRotate
	end
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
	floor.CastShadow = false
	floor.Velocity = ZERO3
	floor.RotVelocity = ZERO3
	floor.CFrame = CONSTANTS.WORLD_CENTER * getRotationBetween(newNormal, UNIT_Y, UNIT_X)
	floor.Parent = self.World

	if self._floorResized then
		self._floorResized:Disconnect()
	end

	self._floorResized = newPart:GetPropertyChangedSignal("Size"):Connect(function()
		floor.Size = newPart.Size
	end)

	self.Floor = floor
end

function PhysicsClass:Destroy()
	if self._floorResized then
		self._floorResized:Disconnect()
		self._floorResized = nil
	end
	self.World:Destroy()
	self.Gyro:Destroy()
end

--

return PhysicsClass