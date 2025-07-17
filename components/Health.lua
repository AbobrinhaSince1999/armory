-- version: "1.0.0"
local Health = {}

function Health.props()
	return {
		maxHp = 100,
		regenRate = 1.2
	}
end

function Health.new()
	local self = {}
	self.name = "Health"
	
	function self:onCreate()
		self.current = self.maxHp	
	end
	
	function self:takeDamage(amount: number)
		self.current = math.clamp(self.current - amount, 0, self.maxHp)
		self:notify("Changed", self.current)
	end
	
	function self:heal(amount: number)
		self.current = math.min(self.current + amount, self.maxHp)
		self:notify("Changed", self.current)
	end

	return self
end

return Health