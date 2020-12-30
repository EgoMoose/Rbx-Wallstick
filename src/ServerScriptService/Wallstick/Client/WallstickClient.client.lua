local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Wallstick = ReplicatedStorage:WaitForChild("Wallstick")
local ReplicatePhysics = Wallstick:WaitForChild("Remotes"):WaitForChild("ReplicatePhysics")

local myPlayer = Players.LocalPlayer
local replicationStorage = {}

ReplicatePhysics.OnClientEvent:Connect(function(player, part, cf, instant, shouldRemove)
	if player == myPlayer then
		return
	end

	if not shouldRemove then
		local storage = replicationStorage[player]

		if not storage then
			storage = {
				Part = part,
				CFrame = cf,
				PrevPart = part,
				PrevCFrame = cf,
				Instant = instant,
			}

			replicationStorage[player] = storage
		end

		storage.Part = part
		storage.CFrame = cf
		storage.Instant = instant
	else
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.Anchored = false
		end
		replicationStorage[player] = nil
	end
end)

Players.PlayerRemoving:Connect(function(player)
	replicationStorage[player] = nil
end)

local function onStep(dt)
	for player, storage in pairs(replicationStorage) do
		if not storage.Part then
			return
		end

		local cf = storage.CFrame

		if not storage.Instant then
			if storage.Part == storage.PrevPart then
				cf = storage.PrevCFrame:Lerp(cf, 0.1*dt*60)
			else
				local prevCFrame = storage.Part.CFrame:ToObjectSpace(storage.PrevPart.CFrame * storage.PrevCFrame)
				cf = prevCFrame:Lerp(cf, 0.1*dt*60)
			end
		end

		storage.PrevPart = storage.Part
		storage.PrevCFrame = cf
		
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.Anchored = true
			character.HumanoidRootPart.CFrame = storage.Part.CFrame * cf
		end 
	end
end

RunService.RenderStepped:Connect(onStep)
--RunService.Heartbeat:Connect(onStep)