-- version: "1.0.0"
_cache = {}

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

function StateMachine(props)
	local self = {}
	self.entry = props.entry or "",
	self.states = props.states or nil,
	self.input = props.input or nil
	self._enabled = true
	self._stack = {}
	self._skipNextUpdate = false

	function self:onCreate()
		if self.entry then
			self:setState(self.entry) -- Set initial state if provided
		end
	end

	-- Handles input and propagates it through states
	function self:handleInput(dt)
		local index = 1
		while index <= #self._stack do
			local state = self._stack[index]
			if not state then return end

			local value = state.handleInput(self.instance, self.input, dt)
			if type(value) == "string" then
				if value == "pass" then
					index += 1 -- advance to next state
				else
					self._skipNextUpdate = true
					self:setState(value)
					return
				end
			else
				return
			end
		end
	end

	-- Updates the current state
	function self:updateState(input, dt)
		local state = self._stack[1]
		if not state then return end

		local value = state.update(self.instance, input, dt)
		if type(value) == "string" then
			self:setState(value) -- Switch state if a new state name is returned
		end
	end

	-- Sets the current state by name
	function self:setState(stateName)
		if self._stack[1] and self._stack[1].name == stateName then return end

		if not stateName or stateName == "" then
			error("State name is invalid!") -- Ensure a valid state name is provided
		end

		-- Exit the current state if it exists and has an exit method
		if self._stack[1] then
			if self._stack[1].exit then
				self._stack[1].exit(self.instance)
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
			self._stack[1].enter(self.instance)
		end
		
		self:notify("StateChanged", self._stack[1].name)
	end

	-- Step function to handle input and update state
	function self:step(dt)
		if not self._enabled then return end

		self:handleInput(dt)

		if not self._skipNextUpdate then
			self:updateState(dt)
		end

		self._skipNextUpdate = false
	end

	return self
end

return StateMachine