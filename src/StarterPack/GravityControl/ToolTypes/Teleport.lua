
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Mouse = Players.LocalPlayer:GetMouse()
local WallstickClass = require(ReplicatedStorage:WaitForChild("Wallstick"))
local wallstick = nil

local params = RaycastParams.new()
params.FilterDescendantsInstances = {}
params.FilterType = Enum.RaycastFilterType.Blacklist

local function lerp(a, b, t)
	return (1 - t)*a + t*b
end

local function getRotationBetween(u, v, axis)
	local dot, uxv = u:Dot(v), u:Cross(v)
	if dot < -0.99999 then return CFrame.fromAxisAngle(axis, math.pi) end
	return CFrame.new(0, 0, 0, uxv.x, uxv.y, uxv.z, 1 + dot)
end

local function getCharHeight()
	local isR15 = wallstick.Humanoid.RigType == Enum.HumanoidRigType.R15
	return isR15 and wallstick.Humanoid.HipHeight + wallstick.Humanoid.RootPart.Size.y/2 + 1 or 3.5
end

local function updateTransition(part, dt)
	if part.Anchored then
		wallstick:SetTransitionRate(0.15)
	else
		wallstick:SetTransitionRate(lerp(wallstick:GetTransitionRate(), 1, 0.1*dt*60))
	end
end

local function onMouseDown()
	local mRay = Mouse.UnitRay
	local result = workspace:Raycast(mRay.Origin, mRay.Direction * 1000, params)

	if result then
		local part = result.Instance
		local normal = part.CFrame:VectorToObjectSpace(result.Normal)

		local hrpCF = wallstick.HRP.CFrame
		local sphericalArc = getRotationBetween(hrpCF.YVector, result.Normal, hrpCF.XVector)
		local teleportCF  = sphericalArc * (hrpCF - hrpCF.p) * CFrame.new(0, getCharHeight(), 0) + result.Position

		updateTransition(part, 0)
		wallstick:Set(part, normal, teleportCF)
	end
end

local module = {}

module.Name = script.Name

function module.equip()
	wallstick = WallstickClass.new(Players.LocalPlayer)
	wallstick.Maid:Mark(Mouse.Button1Down:Connect(onMouseDown))
	wallstick.Maid:Mark(RunService.RenderStepped:Connect(function(dt)
		updateTransition(wallstick.Part, dt)
	end))
	params.FilterDescendantsInstances = {wallstick.Character, wallstick.Physics.World}
end

function module.unequip()
	wallstick:Destroy()
	wallstick = nil
end

return module