-- CONSTANTS

local CONSTANTS = require(script.Parent:WaitForChild("Constants"))

local UNIT_Y = Vector3.new(0, 1, 0)

-- Class

local CameraClass = {}
CameraClass.__index = CameraClass
CameraClass.ClassName = "Camera"

-- Public Constructors

function CameraClass.new(wallstick)
	local self = setmetatable({}, CameraClass)

	local player = wallstick.Player
	local playerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))

	self.Wallstick = wallstick

	self.UpVector = Vector3.new(0, 1, 0)
	self.CameraModule = playerModule:GetCameras()

	init(self)

	return self
end

-- Private methods

function init(self)
	self:SetTransitionRate(0.15)
	self:SetSpinPart(workspace.Terrain)
	function self.CameraModule.GetUpVector(this, upVector)
		return self.UpVector
	end
end

-- Public Methods

function CameraClass:SetMode(mode)
	local camera = workspace.CurrentCamera

	if mode == "Default" then
		camera.CameraSubject = self.Wallstick.Humanoid
	elseif mode == "Custom" then
		self.UpVector = UNIT_Y
		self.CameraModule:SetSpinPart(workspace.Terrain)
		camera.CameraSubject = self.Wallstick.Humanoid
	elseif mode == "Debug" then
		camera.CameraSubject = self.Wallstick.Physics.Humanoid
	end
end

function CameraClass:SetTransitionRate(rate)
	self.CameraModule.TransitionRate = rate
end

function CameraClass:SetSpinPart(part)
	if self.Wallstick.Mode == "Custom" and CONSTANTS.CUSTOM_CAMERA_SPIN then
		self.CameraModule:SetSpinPart(part)
	end
end

function CameraClass:SetUpVector(normal)
	if self.Wallstick.Mode == "Custom" then
		self.UpVector = normal
	end
end

function CameraClass:Destroy()
	self:SetTransitionRate(1)
	self:SetSpinPart(workspace.Terrain)
	function self.CameraModule.GetUpVector(this, upVector)
		return Vector3.new(0, 1, 0)
	end
end

--

return CameraClass