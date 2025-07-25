local HttpService = game:GetService("HttpService")

local Github = {}

local function tree(owner, repo, branch)
	local url = string.format("https://api.github.com/repos/%s/%s/git/trees/%s?recursive=1", repo, owner, branch)
	local json = HttpService:GetAsync(url)
	
	return HttpService:JSONDecode(json).tree
end

function Github.clone(source, owner, repo, branch)
	local srcFolder = Instance.new("Folder")
	local tree = tree(repo, owner, branch)

	for _, node in pairs(tree) do
		if node.path:sub(1, #source) == source and node.type == "blob" then
			local relative = node.path:sub(#source + 2)
			local parts = {}

			for part in relative:gmatch("[^/]+") do table.insert(parts, part) end

			local parent = srcFolder

			for i = 1, #parts - 1 do
				local folder = parent:FindFirstChild(parts[i])

				if not folder then
					folder = Instance.new("Folder")
					folder.Name = parts[i]
					folder.Parent = parent
				end

				parent = folder
			end

			local scriptName = parts[#parts]
			local src = HttpService:GetAsync(string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", owner, repo, branch, node.path))
			local module = Instance.new("ModuleScript")
			module.Name = scriptName:gsub("%.lua$", "")
			module.Source = src
			module.Parent = parent
		end
	end

	return srcFolder
end

return Github