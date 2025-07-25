local function Health(Component)
	local self = Component("Health")

	function self:OnCreate(data)
		self.maxHealth = data.MaxHealth or 100
		self.regenRate = 1.5
		self.current = self.maxHealth
	end

	function self:TakeDamage(amount: number)
		self.current = math.clamp(self.current - amount, 0, self.maxHealth)
		self:Notify("Changed", self.current)
		self:Notify("Damaged", self.current)
	end
	
	function self:Heal(amount: number)
		self.current = math.min(self.current + amount, self.maxHealth)
		self:Notify("Changed", self.current)
		self:Notify("Healed", self.current)
	end

	return self
end

return Health