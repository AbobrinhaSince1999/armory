local src = script.Parent

local Middleware = {}
local _middlewares = {}

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

--_loadMiddlewares()

--[[
	Runs all loaded middleware functions in sequence.
]]
function Middleware.run(context)
	local index = 0

	local function next()
		index += 1
		local fn = _middlewares[index]
		
		if fn then
			fn(context, next)
		end
	end

	next()
end

return Middleware
