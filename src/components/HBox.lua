function HitValidator(hitbox, hurtbox)
	if not hitbox:GetAttribute("enabled") or not hurtbox:GetAttribute("enabled") then
		return
	end
	
	-- add Owner attribute on box shape for better decouple later
	local Armory = require(game.ReplicatedStorage.Armory.Core)
	local hit = Armory.get(hitbox.Parent, "HBox")
	local hurt = Armory.get(hurtbox.Parent, "HBox")
	
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

function HBox(props)
	local self = {}
	self._handle = props.handle or "Default"
	self._shape = props.handle or ""
	self._group = props.group or "Hitbox"
	
	function self:onCreate()
		local shape = self._shape
		shape.CanCollide = false
		shape.CanTouch = false
		shape.CanQuery = true
		shape.CollisionGroup = self._group
		shape.Transparency = 0.5
		shape:SetAttribute("enabled", true)

		if self._group == "Hitbox" then
			self.handler = require(script.handles.hit[self._handle])
		end

		if self._group == "Hurtbox" then
			self.handler = require(script.handles.hurt[self._handle])
		end
	end

	function self:check(hitData)
		return self.handler.check(hitData)
	end

	function self:response(hitData)
		self.handler.response(hitData)
	end

	function self:enable()
		self._shape:SetAttribute("enabled", true)
	end

	function self:disable()
		self._shape:SetAttribute("enabled", false)
	end

	function self:hitTest()
		if self._group ~= "Hitbox" then 
			return warn("[HBox] Only call HitTest on HBox components with Group set to Hitbox")
		end

		local params = OverlapParams.new()
		params.CollisionGroup = "Hitbox"

		-- Gets parts overlapping the hitbox.
		local parts = workspace:GetPartsInPart(self._shape, params)

		-- Validates each overlapping part asynchronously.
		local hitbox = self._shape
		task.defer(function()
			for _, hurtbox in ipairs(parts) do
				HitValidator(hitbox, hurtbox)
			end
		end)
	end

	-- Destroys the Collider and its associated shape.
	function self:onDestroy()
		self._shape:Destroy()
	end

	return self
end

return HBox