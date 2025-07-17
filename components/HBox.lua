-- version: "1.0.0"
local HBox = {}

function HitValidator(hitbox, hurtbox)
	if not hitbox:GetAttribute("enabled") or not hurtbox:GetAttribute("enabled") then
		return
	end
	
	-- add Owner attribute on box shape for better decouple later
	local Armory = require(game.ReplicatedStorage.Armory.Core)
	local hit = Armory.find(hitbox.Parent, "HBox")
	local hurt = Armory.find(hurtbox.Parent, "HBox")
	
	local hitData = {
		hitbox = hit,
		hurtbox = hurt
	}

	local hitCheckPass = hit:check(hitData)
	local hurtCheckPass = hurt:check(hitData)

	if hitCheckPass and hurtCheckPass then
		hit:response(hitData)
		hurt:response(hitData)
		hit:notify("Hitted", hitData)
		hurt:notify("Hurted", hitData)
	end
end


function HBox.props()
	return {
		handle = "Default",
		shape = "",
		group = "Hitbox",
	}
end

function HBox.new()
	local self = {}
	self.name = "HBox"
	
	function self:onCreate()
		local shape = self.shape
		shape.CanCollide = false
		shape.CanTouch = false
		shape.CanQuery = true
		shape.CollisionGroup = self.group
		shape.Transparency = 0.5
		shape:SetAttribute("enabled", true)

		if self.group == "Hitbox" then
			self.handler = require(script.handles.hit[self.handle])
		end

		if self.group == "Hurtbox" then
			self.handler = require(script.handles.hurt[self.handle])
		end
	end

	function self:check(hitData)
		return self.handler.check(hitData)
	end

	function self:response(hitData)
		self.handler.response(hitData)
	end

	function self:enable()
		self.shape:SetAttribute("enabled", true)
	end

	function self:disable()
		self.shape:SetAttribute("enabled", false)
	end

	function self:hitTest()
		if self.group ~= "Hitbox" then 
			return warn("[HBox] Only call HitTest on HBox components with Group set to Hitbox")
		end

		local params = OverlapParams.new()
		params.CollisionGroup = "Hitbox"

		-- Gets parts overlapping the hitbox.
		local parts = workspace:GetPartsInPart(self.shape, params)

		-- Validates each overlapping part asynchronously.
		local hitbox = self.shape
		task.defer(function()
			for _, hurtbox in ipairs(parts) do
				HitValidator(hitbox, hurtbox)
			end
		end)
	end

	-- Destroys the Collider and its associated shape.
	function self:onDestroy()
		self.shape:Destroy()
	end

	return self
end

return HBox