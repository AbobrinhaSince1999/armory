function HitValidator(hitbox, hurtbox)
	if not hitbox:GetAttribute("enabled") or not hurtbox:GetAttribute("enabled") then
		return
	end
	
	-- add Owner attribute on box shape for better decouple later
	local Octus = require(game.ReplicatedStorage.Octus.Core)
	local hit = Octus(hitbox.Parent):Get("HBox")
	local hurt = Octus(hurtbox.Parent):Get("HBox")
	
	local hitData = {
		hitbox = hit,
		hurtbox = hurt
	}

	local hitCheckPass = hit:Check(hitData)
	local hurtCheckPass = hurt:Check(hitData)

	if hitCheckPass and hurtCheckPass then
		hit:Response(hitData)
		hurt:Response(hitData)
		hit:Notify("Hitted", hitData)
		hurt:Notify("Hurted", hitData)
	end
end

function HBox(Component)
	local self = {}
	
	function self:OnCreate(data)
		self._handle = data.handle or "Default"
		self._shape = data.shape or ""
		self._group = data.group or "Hitbox"
		
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

	function self:Check(hitData)
		return self.handler.check(hitData)
	end

	function self:Response(hitData)
		self.handler.response(hitData)
	end

	function self:Enable()
		self._shape:SetAttribute("enabled", true)
	end

	function self:Disable()
		self._shape:SetAttribute("enabled", false)
	end

	function self:HitTest()
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
	function self:OnDestroy()
		self._shape:Destroy()
	end

	return self
end

return HBox