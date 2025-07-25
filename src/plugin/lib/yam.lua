--[[
	YAM (Yet Another Manager 🤗)
	1.0.0
]]

local HttpService = game:GetService("HttpService")
local Github = require(script.Parent.github)

local yam = {}

local function findVersionTag(file)
	return tostring(file.Source:match('version:%s+"(.-)"'))
end

--[[
local function findRemoteVersionTag(owner, repo, branch)
	local src = HttpService:GetAsync(string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", owner, repo, branch, "/armory/core.lua"))
	return src:match('version%s*=%s*"([^"]+)"')
end
]]--

local function updateDependencies(depends, modules)
	local changes = {}
	local dependencies = {}

	for _, module in ipairs(modules:GetChildren()) do 
		dependencies[module.Name] = findVersionTag(module)
		
		if depends[module.Name] == nil then
			table.insert(changes, module.Name)

		elseif depends[module.Name] ~= dependencies[module.Name] then
			table.insert(changes, module.Name)
			
		end
	end
	
	return HttpService:JSONEncode(dependencies), changes
end

-- yam install <package>
function yam.install(source, branch)
	if game.ReplicatedStorage:FindFirstChild("Octus") then
		return warn("[yam] Armory already installed!")
	end
	
	print("💿 Installing!")
	
	local lib = Github.clone(source, "AbobrinhaSince1999", "armory", branch)
	lib.Name = "Octus"
	lib.Parent = game.ReplicatedStorage
	
	--[[
	local components = Github.clone("components", "AbobrinhaSince1999", "armory", "develop")
	components.Name = "components"
	components.Parent = armory
	
	local dependencies = updateDependencies({}, components)

	local package = Instance.new("Configuration")
	package.Name = "package"
	package:SetAttribute("dependencies", dependencies)
	package.Parent = armory	
	]]
	
	print("👍 Installed!")
end

-- yam update <package>
function yam.update()
	if not game.ReplicatedStorage:FindFirstChild("Armory") then
		return warn("[yam] Armory isn't installed!")
	end
	
	local pkg = game.ReplicatedStorage.Armory.package
	local comps = Github.clone("components", "AbobrinhaSince1999", "armory", "main")
	local depends, changes = updateDependencies(HttpService:JSONDecode(pkg:GetAttribute("dependencies")), comps)
	
	if #changes > 0 then
		local src = game.ReplicatedStorage.Armory.components
		for _, name in ipairs(changes) do
			local module = src:FindFirstChild(name)
			if not module then
				comps[name].Parent = src
			else
				module.Source = comps[name].Source
			end
		end
		
		pkg:SetAttribute("dependencies", depends)
		
		warn("🚀 Components has updated!")
	else
		warn("👍 Everything is updated!")
	end
end

return yam
