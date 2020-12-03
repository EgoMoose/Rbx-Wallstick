-- Class

local AnimationClass = {}
AnimationClass.__index = AnimationClass
AnimationClass.ClassName = "Animation"

-- Public Constructors

function AnimationClass.new(wallstick)
	local self = setmetatable({}, AnimationClass)

	self.Wallstick = wallstick
	self.Animate = wallstick.Character:WaitForChild("Animate")
	self.ReplicatedHumanoid = self.Animate:WaitForChild("ReplicatedHumanoid")

	init(self)

	return self
end

-- Private methods

function init(self)
	local loaded = self.Animate:WaitForChild("Loaded")
	while not loaded.Value do
		loaded.Changed:Wait()
	end

	self.ReplicatedHumanoid.Value = self.Wallstick.Physics.Humanoid
end

-- Public Methods

function AnimationClass:Destroy()
	self.ReplicatedHumanoid.Value = self.Wallstick.Humanoid
end

--

return AnimationClass