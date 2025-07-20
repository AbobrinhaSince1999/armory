local src = script.Parent
local Observer = require(src.mixins.observer)

local Factory = {}
local _cache = {}

function Factory.build(name: string, props: { [string]: any }, instance: Instance): any
	if not _cache[name] then
		_cache[name] = require(src.components[name])
	end
	
	local baseComponent = _cache[name]

	local comp = baseComponent(props)
	comp.name = name
	comp.instance = instance

	--[[
	function comp:free()
		self:clearEvents()
		self._dead = true
	end
	]]

	Observer(comp)

	if comp.onCreate then
		task.spawn(comp.onCreate, comp)
	end

	return comp
end

return Factory
