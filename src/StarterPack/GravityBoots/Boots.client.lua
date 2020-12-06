local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Tool = script.Parent
local WallstickClass = require(ReplicatedStorage:WaitForChild("Wallstick"))
local wallstick = nil

local prevTick = -1
local isFalling = false
local renderStep = false

local params = RaycastParams.new()
params.FilterDescendantsInstances = {}
params.FilterType = Enum.RaycastFilterType.Blacklist

local function lerp(a, b, t)
	return (1 - t)*a + t*b
end

local function getCastHeight()
	return wallstick.Humanoid.HipHeight + wallstick.Humanoid.RootPart.Size.y/2 + 1
end

local function updateTransition(part, dt)
	if part.Anchored and not part.ClassName:match("Seat") then
		wallstick:SetTransitionRate(0.15)
	else
		wallstick:SetTransitionRate(lerp(wallstick:GetTransitionRate(), 1, 0.1*dt*60))
	end
end

local function raycast()
	local part = isFalling and workspace.Terrain or wallstick.Part
	local normal = isFalling and Vector3.new(0, 1, 0) or wallstick.Normal
	
	local worldNormal = wallstick.Part.CFrame:VectorToWorldSpace(wallstick.Normal)
	local result = workspace:Raycast(wallstick.HRP.Position, -getCastHeight() * worldNormal, params)

	if result and result.Instance.CanCollide and not Players:GetPlayerFromCharacter(result.Instance.Parent) then
		part = result.Instance
		normal = part.CFrame:VectorToObjectSpace(result.Normal)
	end

	return part, normal
end

local function onHeartbeat(dt)
	local part, normal = raycast()

	local t = os.clock()
	renderStep = false

	if t - prevTick > 0.3 and part ~= wallstick.Part then
		updateTransition(part, dt)
		wallstick:Set(part, normal)
		prevTick = t
	elseif part == wallstick.Part then
		if normal ~= wallstick.Normal then
			updateTransition(wallstick.Part, dt)
			renderStep = true
		end
	else
		updateTransition(wallstick.Part, dt)
	end
end

local function onRenderStep(dt)
	if renderStep then
		wallstick:Set(raycast())
	end
end

Tool.Equipped:Connect(function()
	wallstick = WallstickClass.new(Players.LocalPlayer)
	wallstick.Maid:Mark(RunService.Heartbeat:Connect(onHeartbeat))
	wallstick.Maid:Mark(RunService.RenderStepped:Connect(onRenderStep))
	wallstick.Maid:Mark(RunService.Heartbeat:Connect(function()
		local height, distance = wallstick:GetFallHeight()
		isFalling = (distance < -50)
	end))
	params.FilterDescendantsInstances = {wallstick.Character, wallstick.Physics.World}
end)

Tool.Unequipped:Connect(function()
	wallstick:Destroy()
	wallstick = nil
	renderStep = false
end)