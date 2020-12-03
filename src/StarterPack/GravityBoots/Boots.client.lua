local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Tool = script.Parent
local WallstickClass = require(ReplicatedStorage:WaitForChild("Wallstick"))
local wallstick = nil

local prevTick = -1
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

local function onStep(dt)
	local prevPart = wallstick.Part
	local prevNormal = wallstick.Normal

	local worldNormal = prevPart.CFrame:VectorToWorldSpace(prevNormal)
	local result = workspace:Raycast(wallstick.HRP.Position, -20 * worldNormal, params)

	if result then
		local part = result.Instance
		local normal = part.CFrame:VectorToObjectSpace(result.Normal)

		local t = os.clock()
		if t - prevTick > 0.2 and part ~= prevPart then
			updateTransition(part, dt)
			wallstick:Set(part, normal)
			prevTick = t
			return
		end
	end

	updateTransition(prevPart, dt)
end

Tool.Equipped:Connect(function()
	wallstick = WallstickClass.new(Players.LocalPlayer)
	wallstick.Maid:Mark(RunService.RenderStepped:Connect(onStep))
	wallstick.Maid:Mark(wallstick.Falling:Connect(function(height, distance)
		if distance > 100 then
			wallstick:Set(workspace.Terrain, Vector3.new(0, 1, 0))
		end
	end))
	params.FilterDescendantsInstances = {wallstick.Character, wallstick.Physics.World}
end)

Tool.Unequipped:Connect(function()
	wallstick:Destroy()
	wallstick = nil
end)