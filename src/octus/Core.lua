local src = script.Parent
local Component = require(src.Component)
local Query = require(src.Query)

local _cache = {}
local _components = {}

local function _lazyLoad(name)
	if not _cache[name] then
		_cache[name] = require(script.Parent.Components[name])
	end
	return _cache[name]
end

local function ComponentHandler(_, instance: Instance)
	local self = {}
	self.instance = instance 
	
	function self:Add(name: string, data: { [string]: any })
		_components[self.instance] = _components[self.instance] or {}

		-- Returns the existing one if already attached.
		if _components[self.instance][name] then
			return _components[self.instance][name]
		end

		local comp = _lazyLoad(name)(Component)		
		_components[self.instance][name] = comp
		
		comp.parent = self.instance
		comp:OnCreate(data)

		Query.Update(_components)

		return self
	end

	-- Retrieve a component added to an instance.
	function self:Get(name: string)
		return _components[self.instance] and _components[self.instance][name] or nil
	end

	-- Remove a component from an instance.
	function self:Remove(name: string)
		local compSet = _components[self.instance]

		if compSet and compSet[name] then
			local comp = compSet[name]

			task.spawn(comp.OnDestroy, comp)
			
			comp:ClearEvents()
			compSet[name] = nil

			-- Remove empty table
			if next(compSet) == nil then
				_components[self.instance] = nil
			end
			
			Query.Update(_components)
		end
	end
	
	function self:All()
		return _components[self.instance]
	end

	--[[ Attach multiple compenents
	function Component.batch(instance, comps)
		for name, props in pairs(comps) do
			Component.attach(name, props, instance)
		end
	end]]

	return self
end

local Core = setmetatable({}, {
    __call = ComponentHandler,
	__index = function(_, key)
        return Query[key]
    end
})

return Core