function Timer(Component)
	local self = Component("Timer")

    function self:OnCreate(data)
        self.stopped = true
        self.paused = false
        self.destroyed = false
        self.startedLoop = false
        self.current = data.reverse and 0 or data.duration
        self.duration = data.duration
        self.target = data.duration
        self.reverse = data.reverse or false
        self.tickRate = data.tickRate or 1
    end

    function self:Start()
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

    function self:Stop()
        self.stopped = true
        self.paused = false
    end

    function self:Pause()
        if not self.stopped then
            self.paused = true
        end
    end

    function self:Resume()
        if not self.stopped and self.paused then
            self.paused = false
        end
    end

    function self:Restart()
        self.paused = false
        if self.reverse then
            self.current = 0
        else
            self.current = self.initialValue
        end
        self.stopped = false
    end

    function self:CountDown()
        self.current = math.max(0, self.current - self.tickRate)
        self:notify("Changed", self.current)

        if self.current <= 0 then
            self.stopped = true
            self:notify("Finished")
        end
    end

    function self:CountUp()
        self.current = math.min(self.current + self.tickRate, self.target)
        self:notify("Changed", self.current)

        if self.current >= self.target then
            self.stopped = true
            self:notify("Finished")
        end
    end

    function self:OnDestroy()
        self.stopped = true
        self.destroyed = true
    end

	return self
end

return Timer
