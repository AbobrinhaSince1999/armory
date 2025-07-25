local function Component(name: string)
    local self = {}
    self.name = name
	self.parent = nil
    self._events = {}

    -- init
    function self:OnCreate()
    end

    function self:OnUpdate()
    end

    function self:OnDestroy()
    end

    function self:Sub(event: string, callback: EventCallback)
		self._events[event] = self._events[event] or {}
		table.insert(self._events[event], callback)
	end

	function self:Unsub(event: string, callback: EventCallback)
		local listeners = self._events[event]
		if not listeners then return end

		for i = #listeners, 1, -1 do
			if listeners[i] == callback then
				table.remove(listeners, i)
			end
		end
	end

	function self:Notify(event: string, ...: any)
		local listeners = self._events[event]
		if listeners then
			for _, cb in ipairs(listeners) do
				task.spawn(cb, ...)
			end
		end
	end

    function self:ClearEvents()
        self._events = nil
    end

	return self
end

return Component