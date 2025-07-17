--!strict
local src = script.Parent

--[[
	Middleware
	---------------------------
	This module loads and executes middleware functions in sequence.
	Each middleware receives a `context` table (of type `T`) and a `next()` callback 
	to continue the chain. Inspired by Express.js-style middleware patterns.

	Example middleware:
	```lua
	return function(context, next)
		print("Before")
		next()
		print("After")
	end
	```
]]

export type Context<T> = T
export type MiddlewareFn<T> = (context: Context<T>, next: () -> ()) -> ()

local Middleware = {}
local _middlewares: { any } = {}

--[[
	Loads all middleware modules from `src.middlewares`.
	Only modules returning a function are considered valid middleware.
]]
local function _loadMiddlewares()
	for _, module in ipairs(src.middlewares:GetChildren()) do
		local success, result = pcall(require, module)

		if success and type(result) == "function" then
			table.insert(_middlewares, result)
		else
			warn("[Middleware] Failed to load:", module:GetFullName())
		end
	end
end

-- Load once on module require
_loadMiddlewares()

--[[
	Runs all loaded middleware functions in sequence.

	@param context - The shared context passed through the chain
	@within Middleware
]]
function Middleware.run<T>(context: Context<T>)
	local middlewares = _middlewares :: { MiddlewareFn<T> }

	local index = 0

	local function next()
		index += 1
		local fn = middlewares[index]
		if fn then
			fn(context, next)
		end
	end

	next()
end

return Middleware
