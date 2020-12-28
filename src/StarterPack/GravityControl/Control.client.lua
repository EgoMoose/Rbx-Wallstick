local tool = script.Parent
local equipped = nil
local toolTypes = {}

local function setEquipped(module)
	if equipped then
		equipped.unequip()
	end

	equipped = module
	equipped.equip()

	tool.Name = module.Name
end

local index = 1
for i, module in pairs(script.Parent:WaitForChild("ToolTypes"):GetChildren()) do
	toolTypes[i] = require(module)
	if toolTypes[i].Name == "None" then
		index = i
		setEquipped(toolTypes[i])
	end
end

tool.Equipped:Connect(function()
	index = index % #toolTypes + 1
	setEquipped(toolTypes[index])
end)