--!strict

--[[
	Observable
	----------
	An object that supports basic event subscription and notification.
	Similar to an event emitter, allows objects to communicate in a decoupled way.

	@example
	local observable = Observer(someTable)
	observable:on("Update", function(data) print(data) end)
	observable:notify("Update", "Hello!")

	@field _events Internal event storage table
	@field on Subscribe to an event
	@field off Unsubscribe from an event
	@field notify Notify all listeners for a given event
	@field clearEvents Remove all listeners from all events
]]
export type EventCallback = (...any) -> ()
export type Observable = {
	_events: { [string]: { EventCallback } },

	on: (self: Observable, event: string, callback: EventCallback) -> (),
	off: (self: Observable, event: string, callback: EventCallback) -> (),
	notify: (self: Observable, event: string, ...any) -> (),
	clearEvents: (self: Observable) -> (),
}

--[[
	Observer
	--------
	Adds observable/event-emitting behavior to a target object.
	Provides `.on`, `.off`, `.notify`, and `.clearEvents` methods.

	@param target any -- The table to enhance with observable methods
	@return Observable -- The modified object with observable functionality

	@within Observer
]]
local function Observer(target: any): Observable
	target._events = {} :: { [string]: { EventCallback } }

	--[[
		Registers a callback to be called when the given event is triggered.

		@param event string -- Name of the event
		@param callback EventCallback -- Function to be called when the event fires
	]]
	function target:on(event: string, callback: EventCallback)
		self._events[event] = self._events[event] or {}
		table.insert(self._events[event], callback)
	end

	--[[
		Removes a previously registered callback for the given event.

		@param event string -- Name of the event
		@param callback EventCallback -- The callback function to remove
	]]
	function target:off(event: string, callback: EventCallback)
		local listeners = self._events[event]
		if not listeners then return end

		for i = #listeners, 1, -1 do
			if listeners[i] == callback then
				table.remove(listeners, i)
			end
		end
	end

	--[[
		Triggers an event and calls all associated callbacks with the provided arguments.

		@param event string -- Name of the event
		@param ... any -- Arguments to pass to the callbacks
	]]
	function target:notify(event: string, ...: any)
		local listeners = self._events[event]
		if listeners then
			for _, cb in ipairs(listeners) do
				task.spawn(cb, ...)
			end
		end
	end

	--[[
		Clears all registered event callbacks.
	]]
	function target:clearEvents()
		self._events = {}
	end

	return target
end

return Observer
