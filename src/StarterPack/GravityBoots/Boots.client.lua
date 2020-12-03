local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Tool = script.Parent
local WallstickClass = require(ReplicatedStorage:WaitForChild("Wallstick"))
local wallstick = nil

local prevTick = -1
local isFalling = false
local params = RaycastParams.new()
params.FilterDescendantsInstances = {}
params.FilterType = Enum.RaycastFilterType.Blacklist

local function lerp(a, b, t)
	return (1 - t)*a + t*b
end

local function updateTransition(part, dt)
	if part.Anchored then
		wallstick:SetTransitionRate(0.15)
	else
		wallstick:SetTransitionRate(lerp(wallstick:GetTransitionRate(), 1, 0.1*dt*60))
	end
end

local function getCastHeight()
	return wallstick.Humanoid.HipHeight + wallstick.Humanoid.RootPart.Size.y/2 + 1
end

local function onStep(dt)
	local prevPart = wallstick.Part
	local prevNormal = wallstick.Normal
	local part = isFalling and workspace.Terrain or prevPart
	local normal = isFalling and Vector3.new(0, 1, 0) or prevNormal

	local worldNormal = prevPart.CFrame:VectorToWorldSpace(prevNormal)
	local result = workspace:Raycast(wallstick.HRP.Position, -getCastHeight() * worldNormal, params)

	if result then
		part = result.Instance
		normal = part.CFrame:VectorToObjectSpace(result.Normal)
	end

	local t = os.clock()
	if t - prevTick > 0.2 and part ~= prevPart then
		updateTransition(part, dt)
		wallstick:Set(part, normal)
		prevTick = t
	else
		updateTransition(prevPart, dt)
	end
end

Tool.Equipped:Connect(function()
	wallstick = WallstickClass.new(Players.LocalPlayer)
	wallstick.Maid:Mark(RunService.RenderStepped:Connect(onStep))
	wallstick.Maid:Mark(wallstick.Falling:Connect(function(height, distance)
		isFalling = (distance > 5)
	end))
	params.FilterDescendantsInstances = {wallstick.Character, wallstick.Physics.World}
end)

Tool.Unequipped:Connect(function()
	wallstick:Destroy()
	wallstick = nil
end)