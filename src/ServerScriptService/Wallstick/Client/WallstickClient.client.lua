local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Wallstick = ReplicatedStorage:WaitForChild("Wallstick")
local ReplicatePhysics = Wallstick:WaitForChild("Remotes"):WaitForChild("ReplicatePhysics")

local myPlayer = Players.LocalPlayer
local replicationStorage = {}

ReplicatePhysics.OnClientEvent:Connect(function(player, part, cf, shouldRemove)
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
			}

			replicationStorage[player] = storage
		end

		storage.Part = part
		storage.CFrame = cf
	else
		replicationStorage[player] = nil
	end
end)

Players.PlayerRemoving:Connect(function(player)
	replicationStorage[player] = nil
end)

local function onStep(dt)
	for player, storage in pairs(replicationStorage) do
		local cf = storage.CFrame

		if storage.Part == storage.PrevPart then
			cf = storage.PrevCFrame:Lerp(cf, 0.1*dt*60)
		end

		storage.PrevPart = storage.Part
		storage.PrevCFrame = cf
		
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.CFrame = storage.Part.CFrame * cf
		end 
	end
end

RunService.RenderStepped:Connect(onStep)