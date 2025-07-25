local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

function Input(Component)
	local self = Component("Input")

	function self:OnCreate(data)
		self._bindings = {}
		self._actions = {}
		self._pressed = {}
		self._held = {}
		self._heartbeatConn = nil
		self.keymap = data.keymap or {}

		for name, key in pairs(self.keymap) do
			self:bind(name, key)
		end

		self._heartbeatConn = RunService.Heartbeat:Connect(function()
			for name, isHeld in pairs(self._pressed) do
				if isHeld then
					self:Notify(name, "held")
				end
			end
		end)
	end

	function self:OnDestroy()
		for name in pairs(self._actions) do
			ContextActionService:UnbindAction(name)
		end
		if self._heartbeatConn then
			self._heartbeatConn:Disconnect()
		end
	end

	function self:Bind(name: string, key)
		self:unbind(name)
		self._bindings[name] = key

		local function handler(_, inputState)
			if inputState == Enum.UserInputState.Begin then
				self._pressed[name] = true
				self:notify(name, "pressed")
				
			elseif inputState == Enum.UserInputState.End then
				self._pressed[name] = false
				self:notify(name, "released")
				
			end
			
			return Enum.ContextActionResult.Sink
		end

		ContextActionService:BindAction(name, handler, false, key)
		self._actions[name] = true
	end

	function self:Unbind(name: string)
		if self._actions[name] then
			ContextActionService:UnbindAction(name)
			self._actions[name] = nil
			self._bindings[name] = nil
			self._pressed[name] = nil
		end
	end

	function self:Holding(name: string): boolean
		return self._pressed[name] == true
	end
	
	function self:Released(name: string): boolean
		return not self:holding(name)
	end

	function self:GetBinding(name: string)
		return self._bindings[name]
	end

	return self
end

return Input
