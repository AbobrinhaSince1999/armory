-- version: "1.0.0"
local AnimPlayer = {}

function AnimPlayer.props()
	return {
		source = "path/to/anims"
	}
end

function AnimPlayer.new()
	local self = {}
	self._animator = nil
	self._tracks = {}
	self._lastPlayedTrack = nil

	function self:onCreate()
		local humanoid = self.instance:FindFirstChild("Humanoid")
		
		if humanoid then
			self._animator = humanoid.Animator

		else
			local animationController = Instance.new("AnimationController")
			animationController.Parent = self.instance

			local animator = Instance.new("Animator")
			animator.Parent = animationController

			self._animator = animator

		end

		for _, animation in ipairs(self.source:GetChildren()) do
			self:load(animation)
		end
	end

	function self:play(name: string, ...)
		self:stop()
		self._lastPlayedTrack = self._tracks[name]
		self._lastPlayedTrack:Play(...)
	end

	function self:isPlaying(name): boolean
		local track = self._tracks[name]
		return track and track.IsPlaying
	end

	function self:stop()
		if self._lastPlayedTrack then
			self._lastPlayedTrack:Stop()
			self._lastPlayedTrack = nil
		end
	end
	
	function self:load(data)
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

return AnimPlayer