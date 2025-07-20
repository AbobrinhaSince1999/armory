--[[
	Observer

	Adds observable/event-emitting behavior to a target object.
	Provides `.on`, `.off`, `.notify`, and `.clearEvents` methods.
]]
local function Observer(target: any): Observable
	target._events = {}

	function target:on(event: string, callback: EventCallback)
		self._events[event] = self._events[event] or {}
		table.insert(self._events[event], callback)
	end

	function target:off(event: string, callback: EventCallback)
		local listeners = self._events[event]
		if not listeners then return end

		for i = #listeners, 1, -1 do
			if listeners[i] == callback then
				table.remove(listeners, i)
			end
		end
	end

	function target:notify(event: string, ...: any)
		local listeners = self._events[event]
		if listeners then
			for _, cb in ipairs(listeners) do
				task.spawn(cb, ...)
			end
		end
	end

	function target:clearEvents()
		self._events = {}
	end

	return target
end

return Observer
