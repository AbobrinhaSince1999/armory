local src = script.Parent
local Factory = require(src.factory)
local Query = require(src.query)
--local Middleware = require(src.middleware)

local Component = {}
local _attached = {}

-- Attach a component to an instance.
function Component.attach(name: string, props: { [string]: any }, instance: Instance)
	_attached[instance] = _attached[instance] or {}

	-- Returns the existing one if already attached.
	if _attached[instance][name] then
		return _attached[instance][name]
	end

	local comp = Factory.build(name, props, instance)
	_attached[instance][name] = comp
	
	Middleware.run({
		type = "attach",
		instance = instance,
		component = comp
	})
	
	-- Invalidate cache
	Query.update(_attached)
	
	return comp
end

-- Attach multiple compenents
function Component.batch(instance, comps)
	for name, props in pairs(comps) do
		Component.attach(name, props, instance)
	end
end

-- Retrieve a component attached to an instance.
function Component.get(name: string, instance: Instance)
	return _attached[instance] and _attached[instance][name] or nil
end

-- Detach a component from an instance.
function Component.detach(name: string, instance: Instance)
	local compSet = _attached[instance]

	if compSet and compSet[name] then
		local comp = compSet[name]

		if comp.onDestroy then
			task.spawn(comp.onDestroy, comp)
		end

		comp:clearEvents()
		compSet[name] = nil

		-- Remove empty table
		if next(compSet) == nil then
			_attached[instance] = nil
		end
		
		Middleware.run({
			type = "detach",
			instance = instance,
			component = comp
		})

		-- Invalidate cache
		Query.update(_attached)
	end
end

return Armory
