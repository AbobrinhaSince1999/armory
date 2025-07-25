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

function BlendTree2D(Component)
	local self = Component("BlendTree2D")
	
	function self:OnCreate(data)
		self._rawInputVector = Vector2.zero
		self._inputVector = Vector2.zero
		self._weightThreshold = 0.05
		self._nodes = {}
		self._maxSpeed = data.maxSpeed or 16
		self._lerpSpeed = data.lerpSpeed or 10

	    for _, node in ipairs(data.nodes) do
            table.insert(self._nodes, {
                position = node.position,
                track = node.track,
                weight = 0
            })

            node.track:Play()
            node.track:AdjustWeight(0)
        end

		self._renderSteppedConn = RunService.RenderStepped:Connect(function(dt)
			self:_UpdateNodesWeight()
		end)
	end

    function self:_UpdateNodesWeight(dt)
        self._inputVector = self._inputVector:Lerp(self._rawInputVector, dt * self._lerpSpeed)
        local weights = calculateBlendWeights(self._inputVector, self._nodes)

        for i, node in ipairs(self._nodes) do
            node.weight = math.lerp(node.weight, weights[i], dt * self._lerpSpeed)
            local adjustedWeight = (node.weight > self._weightThreshold) and node.weight or 0
            node.track:AdjustWeight(adjustedWeight)
        end
    end

	function self:SetInput(rawInput)
		self._rawInputVector = rawInput
	end
        
    function self:OnDestroy()
        if self._renderSteppedConn then
		    self._renderSteppedConn:Disconnect()
	    end
    end

	return self
end

return BlendTree2D