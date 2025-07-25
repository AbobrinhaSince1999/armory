--[[
	API:
	- Query.Update(attached):Clears cache and filters. Injects component attachment data (required)
	- Query.Has(...components): Adds a filter for instances with ALL listed components.
	- Query.Only(...components): Adds a filter for instances with ONLY listed components.
	- Query.Not(...components): Adds a filter for instances WITHOUT any of the listed components.
	- Query.Where(fn): Adds a custom filter function.
	- Query.All(): Returns all instances that pass the current filters.
]]

local Query = {}

local _cache = {}
local _filters = {}
local _components = {}

-- Injects external attached component map
function Query.Update(list)
	_cache = {}
	_filters = {}
	_components = list
end

-- Must have all listed components
function Query.Has(...: string)
	local params = { ... }

	table.insert(_filters, function(_, comps)
		for _, name in ipairs(params) do
			if comps[name] == nil then return false end
		end

		return true
	end)

	return Query
end

-- Must have only the listed components
function Query.Only(...: string)
	local params = {...}
	local required = {}
	
	for _, name in ipairs(params) do
		required[name] = true
	end

	table.insert(_filters, function(_, comps)
		for name in pairs(comps) do
			if not required[name] then return false end
		end

		for name in pairs(required) do
			if comps[name] == nil then return false end
		end

		return true
	end)

	return Query
end

-- Must not have any of the listed components
function Query.Not(...: string)
	local params = {...}

	table.insert(_filters, function(_, comps)
		for _, name in ipairs(params) do
			if comps[name] then return false end
		end

		return true
	end)

	return Query
end

-- Custom filter logic
function Query.Where(fn)
	table.insert(_filters, fn)
	return Query
end

-- Returns all matching instances based on current filters
function Query.All(): { Instance }
	local results: { Instance } = {}

	if not _components then
		error("[Query] No attached component map. Use Query.update(...) first.")
	end

	for instance, comps in _components do
		if _cache[instance] == nil then
			local passed = true

			for _, filter in ipairs(_filters) do
				if not filter(instance, comps) then
					passed = false
					break
				end
			end

			_cache[instance] = passed
		end

		if _cache[instance] then
			table.insert(results, instance)
		end
	end

	return results
end

-- Applies a callback function to each instance in the list.
function Query.ForEach(instances: { Instance }, callback: (Instance) -> ())
	for _, instance in ipairs(instances) do
		callback(instance)
	end
end

return Query
