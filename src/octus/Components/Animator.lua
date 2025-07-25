function Animator(Component)
	local self = Component("Animator")

	function self:OnCreate(data)
		self._animator = nil
		self._tracks = {}

		local humanoid = self.parent:FindFirstChild("Humanoid")
		if humanoid then
			self._animator = humanoid.Animator
		else
			local animationController = Instance.new("AnimationController")
			animationController.Parent = self.parent

			local animator = Instance.new("Animator")
			animator.Parent = animationController

			self._animator = animator
		end

		for _, animation in ipairs(data.Animations:GetChildren()) do
			self:Load(animation)
		end
	end

	function self:Play(name: string, ...)
		self:Stop(name)
		self._tracks[name]:Play(...)
	end

	function self:IsPlaying(name): boolean
		return self._tracks[name] and self._tracks[name].IsPlaying
	end

	function self:Stop(name)
		self._tracks[name]:Stop()
	end
	
	function self:Load(data)
		-- { "idle", "rbxassetid://12345" } or Animation
		local animation = data
		
		if type(data) == "table" then
			animation = Instance.new("Animation")
			animation.Name = data[1]
			animation.AnimationId = data[2]
		end
		
		if self._tracks[animation.Name] then return end
		self._tracks[animation.Name] = self._animator:LoadAnimation(animation)
	end
	
	return self
end

return Animator