local Players = game:GetService("Players")

local tool = script.Parent
local platform = nil

tool.Equipped:Connect(function()
	local character = tool.Parent
	if not (character and character.PrimaryPart) then
		return
	end

	local player = Players:GetPlayerFromCharacter(tool.Parent)

	platform = Instance.new("Part")
	platform.Size = Vector3.new(5, 1, 5)

	local object = Instance.new("ObjectValue")
	object.Name = player.UserId
	object.Value = platform
	object.Parent = workspace.Platforms

	local weld = Instance.new("Weld")
	weld.C0 = CFrame.new(0, 3, 5)
	weld.Part0 = character.PrimaryPart
	weld.Part1 = platform
	weld.Parent = platform

	platform.Parent = tool
	platform:SetNetworkOwner(player)
	platform.AncestryChanged:Connect(function()
		object:Destroy()
	end)
end)

tool.Unequipped:Connect(function()
	if platform then
		platform:Destroy()
	end
end)