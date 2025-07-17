--!strict
--[[
	Provides a flexible and cache-aware system for filtering instances based on their attached components.

	API:
	- Query.inject(attached): Injects component attachment data (required).
	- Query.reset(): Clears cache and filters.
	- Query.has(...components): Adds a filter for instances with ALL listed components.
	- Query.only(...components): Adds a filter for instances with ONLY listed components.
	- Query.nott(...components): Adds a filter for instances WITHOUT any of the listed components.
	- Query.where(fn): Adds a custom filter function.
	- Query.all(): Returns all instances that pass the current filters.
]]

local Query = {}

export type ComponentTable = { [string]: any }
export type AttachedMap = { [Instance]: ComponentTable }
export type FilterFunction = (Instance, ComponentTable) -> boolean

local _cache: { [Instance]: boolean } = {}
local _attached: AttachedMap? = {}
local _filters: { FilterFunction } = {}

-- Injects external attached component map
function Query.inject(attached: AttachedMap)
	Query.reset()
	_attached = attached
end

-- Clears filters and result cache
function Query.reset()
	_cache = {}
	_filters = {}
end

-- Filter: must have all listed components
function Query.has(...: string)
	local params: { string } = { ... }

	table.insert(_filters, function(_, comps)
		for _, name in ipairs(params) do
			if comps[name] == nil then return false end
		end
		return true
	end)

	return Query
end

-- Filter: must have only the listed components
function Query.only(...: string)
	local params: { string } = { ... }
	local required: { [string]: boolean } = {}
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

-- Filter: must HAS have any of the listed components
function Query.nott(...: string)
	local params: { string } = { ... }

	table.insert(_filters, function(_, comps)
		for _, name in ipairs(params) do
			if comps[name] then return false end
		end
		return true
	end)

	return Query
end

-- Filter: custom logic
function Query.where(fn: FilterFunction)
	table.insert(_filters, fn)
	return Query
end

-- Returns all matching instances based on current filters
function Query.all(): { Instance }
	local results: { Instance } = {}

	if not _attached then
		error("[Query] No attached component map. Use Query.inject(...) first.")
	end

	for instance, comps in _attached do
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

return Query
