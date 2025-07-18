--!strict
-- version: "1.0.0"

--[[
	🤯 A lightweight and flexible component library for Roblox.  
	Plug in components. Build scalable systems. Orchestrate gameplay your way.

	No forced structure. No restrictions.
    Use components your way — plug manually, compose with use-patterns, or run full game systems.

    You decide how deep you go.
]]

local src = script.Parent
local Component = require(src.component)
local Middleware = require(src.middleware)
local Query = require(src.query)

local Armory = {}

local _attached: { [Instance]: { [string]: Component } } = {}

-- Attach a component to an instance.
-- Returns the component, or the existing one if already attached.
function Armory.add(name: string, props: { [string]: any }, instance: Instance)
	_attached[instance] = _attached[instance] or {}

	if _attached[instance][name] then
		return _attached[instance][name]
	end

	local comp = Component.build(name, props, instance)
	_attached[instance][name] = comp
	
	Middleware.run({
		type = "added",
		instance = instance,
		component = comp
	})
	
	Query.inject(_attached) -- Invalidate cache if query is used
	
	return comp
end

-- Attach multiple compenents
function Armory.batch(instance, comps)
	for name, props in pairs(comps) do
		Armory.add(name, props, instance)
	end
end

-- Retrieve a component attached to an instance.
function Armory.get(name: string, instance: Instance)
	return _attached[instance] and _attached[instance][name] or nil
end

-- Detach a component from an instance.
function Armory.remove(name: string, instance: Instance)
	local compSet = _attached[instance]
	if compSet and compSet[name] then
		local comp = compSet[name]

		if comp.onDestroy then
			task.spawn(comp.onDestroy, comp)
		end

		comp:clearEvents()

		compSet[name] = nil

		-- Optionally remove empty table
		if next(compSet) == nil then
			_attached[instance] = nil
		end
		
		Middleware.run({
			type = "removed",
			instance = instance,
			component = comp
		})
		
		Query.inject(_attached) -- Invalidate cache if query is used
	end
end

-- Applies a callback function to each instance in the list.
function Armory.forEach(instances: { Instance }, callback: (Instance) -> ())
	for _, instance in ipairs(instances) do
		callback(instance)
	end
end

return Armory
