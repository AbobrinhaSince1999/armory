-- version: "1.0.0"
local BlendTree = {}

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

function BlendTree.props()
	return {	
        nodes = {}
        maxSpeed = 16,
	    lerpSpeed = 10,
    }
end

function BlendTree.new()
	local self = {}
	self.rawInputVector = Vector2.zero
	self.inputVector = Vector2.zero
	self.weightThreshold = 0.05
	self.nodeGraph = {}

	function self:onCreate()
	    for _, node in ipairs(self.nodes) do
            table.insert(self.nodeGraph, {
                position = node.position,
                track = node.track,
                weight = 0
            })

            node.track:Play()
            node.track:AdjustWeight(0)
        end
	end

    function self:updateNodesWeight(dt)
        self.inputVector = self.inputVector:Lerp(self.rawInputVector, dt * self.lerpSpeed)
        local weights = calculateBlendWeights(self.inputVector, self.nodeGraph)

        for i, node in ipairs(self.nodeGraph) do
            node.weight = math.lerp(node.weight, weights[i], dt * self.lerpSpeed)
            local adjustedWeight = (node.weight > self.weightThreshold) and node.weight or 0
            node.track:AdjustWeight(adjustedWeight)
        end
    end
        
    function self:onDestroy()
        if self._conn then
		    self._conn:Disconnect()
	    end
    end

	return self
end

return BlendTree