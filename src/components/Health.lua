function Health(props)
	local self = {}
	self._maxHp = props.maxHp or 100
	self._regenRate = 1.2
	self._current = self._maxHp

	function self:takeDamage(amount: number)
		self._current = math.clamp(self._current - amount, 0, self._maxHp)
		self:notify("Changed", self._current)
		self:notify("Damaged", self._current)
	end
	
	function self:heal(amount: number)
		self._current = math.min(self._current + amount, self._maxHp)
		self:notify("Changed", self._current)
		self:notify("Healed", self._current)
	end

	function self:value()
		return self._current
	end

	return self
end

return Health