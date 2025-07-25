local _cache = {}

-- Retrieves a state from cache or loads it
local function loadState(folder, stateName)
	if _cache[stateName] then
		return _cache[stateName] -- Return cached state if available
	end

	local stateModule = folder[stateName]
	if not stateModule then
		error("[StateMachine] '" .. tostring(stateName) .. "' isn't found on folder")
	end

	-- Default no-op method for missing state methods
	local function fn(...)end

	-- Load and cache the state
	local state = require(stateModule)
	state.name = stateName
	state.enter = state.enter or fn
	state.exit = state.exit or fn
	state.handleInput = state.handleInput or fn
	state.update = state.update or fn

	_cache[stateName] = state

	return _cache[stateName]
end

function StateMachine(Component)
	local self = Component("StateMachine")

	function self:OnCreate(data)
		self._enabled = true
		self._stack = {}
		self._skipNextUpdate = false
		self.entry = data.entry or ""
		self.states = data.states or nil
		self.input = data.input or nil

		if self.entry then
			self:setState(self.entry) -- Set initial state if provided
		end
	end

	-- Handles input and propagates it through states
	function self:HandleInput(dt)
		local index = 1
		while index <= #self._stack do
			local state = self._stack[index]
			if not state then return end

			local value = state.HandleInput(self.instance, self.input, dt)
			if type(value) == "string" then
				if value == "pass" then
					index += 1 -- advance to next state
				else
					self._skipNextUpdate = true
					self:SetState(value)
					return
				end
			else
				return
			end
		end
	end

	-- Updates the current state
	function self:UpdateState(input, dt)
		local state = self._stack[1]
		if not state then return end

		local value = state.Update(self.parent, input, dt)
		if type(value) == "string" then
			self:SetState(value) -- Switch state if a new state name is returned
		end
	end

	-- Sets the current state by name
	function self:SetState(stateName)
		if self._stack[1] and self._stack[1].name == stateName then return end

		if not stateName or stateName == "" then
			error("State name is invalid!") -- Ensure a valid state name is provided
		end

		-- Exit the current state if it exists and has an exit method
		if self._stack[1] then
			if self._stack[1].exit then
				self._stack[1].exit(self.parent)
			end
		end

		-- Pop the current state or push a new state
		if stateName == "pop" then
			if #self._stack > 0 then
				table.remove(self._stack, 1) -- Pop the top state
			end
		else
			table.insert(self._stack, 1, loadState(self.states, stateName)) -- Push new state to stack
		end

		-- Enter the new state if it has an enter method
		if self._stack[1] and self._stack[1].enter then
			self._stack[1].enter(self.parent)
		end
		
		self:Notify("StateChanged", self._stack[1].name)
	end

	-- Step function to handle input and update state
	function self:Step(dt)
		if not self._enabled then return end

		self:HandleInput(dt)

		if not self._skipNextUpdate then
			self:UpdateState(dt)
		end

		self._skipNextUpdate = false
	end

	return self
end

return StateMachine