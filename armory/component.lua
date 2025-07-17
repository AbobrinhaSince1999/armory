--!strict

--[[
	BaseComponent represents a component definition/module.
	@field new () -> any
	@field props? () -> { [string]: any }
]]
export type BaseComponent = {
	new: () -> any,
	props: (() -> { [string]: any })?
}

--[[
	Component
	-------------
	Dynamically loads component modules from a folder and builds instances with
	optional default props and lifecycle support.

	Each component must export a `.new()` constructor. Optionally, it may provide
	a `.props()` function that returns default properties.
]]

local src = script.Parent
local Observer = require(src.mixins.observer)

local Component = {}
local _components: { [string]: BaseComponent } = {}

--[[
	loadComponents
	-----
	Recursively loads all `ModuleScript`s from the `components` folder
	and registers them in the `_components` table.
]]
local function loadComponents()
	for _, module in ipairs(src.components:GetDescendants()) do
		if module:IsA("ModuleScript") then
			local success, result = pcall(require, module)
			if success and type(result) == "table" then
				_components[module.Name] = result :: BaseComponent
			else
				warn("[Component] Failed to load:", module:GetFullName())
			end
		end
	end
end

loadComponents()

--[[
	Component.build(name: string, props: { [string]: any }?): any
	--------------------------------------------------------------
	Instantiates a component by name, applies default props if defined,
	makes it observable, and calls its `onCreate` lifecycle method.

	@param name string -- Name of the registered component
	@param props? table -- Optional property overrides
	@return any -- Instantiated and configured component
]]
function Component.build(name: string, instance: Instance, props: { [string]: any }?): any
	local component = _components[name]

	if not component then
		error("🤔 [Component] '" .. name .. "' was not found!")
	end

	local comp = component.new()
	comp.name = name
	comp.instance = instance
	
	local defaultProps = component.props and component.props() or {}
	props = props or {}

	for k, v in pairs(defaultProps) do
		comp[k] = props[k] or v
	end

	Observer(comp)

	if comp.onCreate then
		task.spawn(comp.onCreate, comp)
	end

	return comp
end

return Component
