-- Class

local ControlClass = {}
ControlClass.__index = ControlClass
ControlClass.ClassName = "Control"

-- Public Constructors

function ControlClass.new(wallstick)
	local self = setmetatable({}, ControlClass)

	local player = wallstick.Player
	local playerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))

	self.Wallstick = wallstick
	self.ControlModule = playerModule:GetControls()

	return self
end

-- Public Methods

function ControlClass:GetMoveVector()
	return self.ControlModule:GetMoveVector()
end

function ControlClass:Destroy()
	
end

--

return ControlClass