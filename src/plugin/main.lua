local src = script.Parent
local yam = require(src.lib.yam)

local toolbar = plugin:CreateToolbar("Octus Devtools")

local btnInstall = toolbar:CreateButton("Install", "Install a fresh version of Octus lib!", "")
local btnUpdate = toolbar:CreateButton("Update", "Update Components", "")

btnInstall.Click:Connect(function()
	yam.install("src/octus", "beta")
end)

btnUpdate.Click:Connect(function()
	yam.update()
end)
