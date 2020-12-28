local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Wallstick = script.Parent.Parent:WaitForChild("Wallstick")
local RemotesFolder = Wallstick:WaitForChild("Remotes")
local CONSTANTS = require(Wallstick:WaitForChild("Constants"))

local setCollidable = Instance.new("RemoteEvent")
setCollidable.Name = "SetCollidable"
setCollidable.Parent = RemotesFolder

setCollidable.OnServerEvent:Connect(function(player, bool)
	if not player.Character then
		return
	end

	for _, part in pairs(player.Character:GetChildren()) do
		if part:IsA("BasePart") then
			part.CollisionGroupId = not bool and CONSTANTS.PHYSICS_ID or 0
		end
	end
end)

local replicationStorage = {}

local replicatePhysics = Instance.new("RemoteEvent")
replicatePhysics.Name = "ReplicatePhysics"
replicatePhysics.Parent = RemotesFolder

replicatePhysics.OnServerEvent:Connect(function(player, part, cf, shouldRemove)
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

	replicatePhysics:FireAllClients(player, part, cf, shouldRemove)
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

-- This only need to run if you need an accurate character cframe on the server
-- RunService.Heartbeat:Connect(onStep)

return true