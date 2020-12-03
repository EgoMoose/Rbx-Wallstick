local Wallstick = script.Parent.Parent:WaitForChild("Wallstick")
local RemotesFolder = Wallstick:WaitForChild("Remotes")

local replicatePhysics = Instance.new("RemoteEvent")
replicatePhysics.Name = "ReplicatePhysics"
replicatePhysics.Parent = RemotesFolder

replicatePhysics.OnServerEvent:Connect(function(player)

end)

return true