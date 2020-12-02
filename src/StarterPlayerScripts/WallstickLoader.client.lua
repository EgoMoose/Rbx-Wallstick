local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local WallstickClass = require(ReplicatedStorage:WaitForChild("Wallstick"))

Players.LocalPlayer.CharacterAdded:Connect(function(character)
	local wallstick = WallstickClass.new(Players.LocalPlayer)

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {character, wallstick.Physics.World}
	params.FilterType = Enum.RaycastFilterType.Blacklist

	wallstick._maid:Mark(RunService.RenderStepped:Connect(function(dt)
		local prevPart = wallstick.Part
		local prevNormal = wallstick.Normal

		local worldNormal = prevPart.CFrame:VectorToWorldSpace(prevNormal)
		local result = workspace:Raycast(wallstick.HRP.Position, -20 * worldNormal, params)

		if result then
			local part = result.Instance
			local normal = part.CFrame:VectorToObjectSpace(result.Normal)

			if part ~= prevPart or normal:Dot(prevNormal) < 0.9 then
				wallstick:Set(part, normal)
			end
		end
	end))
end)