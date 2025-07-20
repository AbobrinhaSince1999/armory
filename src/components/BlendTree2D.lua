local RunService = game:GetService("RunService")

local function calculateBlendWeights(input, nodes)
	local totalWeight = 0
	local weights = {}

	for i, node in ipairs(nodes) do
		local dist = (input - node.position).Magnitude
		local weight = 1 / math.max(dist, 0.001)
		weights[i] = weight
		totalWeight += weight
	end

	for i = 1, #weights do
		weights[i] = weights[i] / totalWeight
	end

	return weights
end

function BlendTree2D(props)
	local self = {}
	self._rawInputVector = Vector2.zero
	self._inputVector = Vector2.zero
	self._weightThreshold = 0.05
	self._nodes = props.nodes or {}
	self._maxSpeed = props.maxSpeed or 16
	self._lerpSpeed = props.lerpSpeed or 10

	function self:onCreate()
		local nodes = self._nodes
		self._nodes = {}

	    for _, node in ipairs(nodes) do
            table.insert(self._nodes, {
                position = node.position,
                track = node.track,
                weight = 0
            })

            node.track:Play()
            node.track:AdjustWeight(0)
        end

		self._renderSteppedConn = RunService.RenderStepped:Connect(function(dt)
			self:_updateNodesWeight()
		end)
	end

    function self:_updateNodesWeight(dt)
        self._inputVector = self._inputVector:Lerp(self._rawInputVector, dt * self._lerpSpeed)
        local weights = calculateBlendWeights(self._inputVector, self._nodes)

        for i, node in ipairs(self._nodes) do
            node.weight = math.lerp(node.weight, weights[i], dt * self._lerpSpeed)
            local adjustedWeight = (node.weight > self._weightThreshold) and node.weight or 0
            node.track:AdjustWeight(adjustedWeight)
        end
    end

	function self:setInput(rawInput)
		self._rawInputVector = rawInput
	end
        
    function self:onDestroy()
        if self._renderSteppedConn then
		    self._renderSteppedConn:Disconnect()
	    end
    end

	return self
end

return BlendTree2D