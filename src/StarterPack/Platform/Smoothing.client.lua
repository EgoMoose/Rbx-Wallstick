local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local UserId = tostring(Players.LocalPlayer.UserId)
local Platforms = workspace.Platforms

local function startSmoothing(object)
	while not object.Value do
		object.Changed:Wait()
	end

	local platform = object.Value

	if object.Name == UserId then
		platform.CanCollide = false
		return
	end

	local weld = platform:WaitForChild("Weld")
	weld.Parent = nil
	platform.Anchored = true

	local hb = RunService.Heartbeat:Connect(function(dt)
		platform.CFrame = weld.Part0.CFrame * weld.C0
	end)
	
	platform.AncestryChanged:Connect(function()
		hb:Disconnect()
	end)
end

for _, object in pairs(Platforms:GetChildren()) do
	startSmoothing(object)
end

Platforms.ChildAdded:Connect(startSmoothing)