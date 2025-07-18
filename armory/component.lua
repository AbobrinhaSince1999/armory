local src = script.Parent
local Observer = require(src.mixins.observer)

local Component = {}
local _cache = {}

local function loadComponents()
	for _, module in ipairs(src.components:GetDescendants()) do
		if module:IsA("ModuleScript") then
			local success, result = pcall(require, module)
			if success then
				_cache[module.Name] = result
			else
				warn("[Component] Failed to load:", module:GetFullName())
			end
		end
	end
end

loadComponents()

function Component.build(name: string, props: { [string]: any }, instance: Instance): any
	local component = _cache[name]

	if not component then
		error("🤔 [Component] '" .. name .. "' was not found!")
	end

	local comp = component(props)
	comp.name = name
	comp.instance = instance

	Observer(comp)

	if comp.onCreate then
		task.spawn(comp.onCreate, comp)
	end

	return comp
end

return Component
