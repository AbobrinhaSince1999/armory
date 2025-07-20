function Timer(props)
	local self = {}
	self.stopped = true
	self.paused = false
	self.destroyed = false
	self.startedLoop = false
    self.current = props.reverse and 0 or props.duration,
	self.target = props.duration,
	self.initialValue = props.duration,
	self.reverse = props.reverse or false,
	self.tickRate = props.tickRate or 1,

    function self:start()
        self.stopped = false
        self.paused = false

        if not self.startedLoop then
            self.startedLoop = true

            coroutine.wrap(function()
                while not self.destroyed do
                    if not self.stopped and not self.paused then
                        if self.reverse then
                            self:countUp()
                        else
                            self:countDown()
                        end
                    end
                    wait(self.tickRate)
                end
            end)()
        end
    end

    function self:stop()
        self.stopped = true
        self.paused = false
    end

    function self:pause()
        if not self.stopped then
            self.paused = true
        end
    end

    function self:resume()
        if not self.stopped and self.paused then
            self.paused = false
        end
    end

    function self:restart()
        self.paused = false
        if self.reverse then
            self.current = 0
        else
            self.current = self.initialValue
        end
        self.stopped = false
    end

    function self:countDown()
        self.current = math.max(0, self.current - self.tickRate)
        self:notify("Changed", self.current)

        if self.current <= 0 then
            self.stopped = true
            self:notify("Finished")
        end
    end

    function self:countUp()
        self.current = math.min(self.current + self.tickRate, self.target)
        self:notify("Changed", self.current)

        if self.current >= self.target then
            self.stopped = true
            self:notify("Finished")
        end
    end

    function self:value()
        return self.current
    end

    function self:onDestroy()
        self.stopped = true
        self.destroyed = true
    end

	return self
end

return Timer
