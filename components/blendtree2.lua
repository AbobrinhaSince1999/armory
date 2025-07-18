--[[
-- LEAN: based on acceleration (velocity delta)
local accel = (velocity - self.LastVelocity) / math.max(dt, 0.001)
local accelX = right:Dot(accel)
local accelY = forward:Dot(accel)

local tiltX = math.clamp(-accelY * self.LeanStrength, -30, 30)
local tiltZ = math.clamp(accelX * self.LeanStrength, -30, 30)

local currentCF = self.LeanPart.CFrame
local targetTilt = CFrame.Angles(math.rad(tiltX), 0, math.rad(tiltZ))
local smoothTilt = currentCF.Rotation:Lerp(targetTilt.Rotation, dt * self.LeanSpeed)
self.LeanPart.CFrame = CFrame.new(self.LeanPart.Position) * smoothTilt

self.LastVelocity = velocity

local function inputRelativeToCamera(inputDir: Vector2, velocity: Vector3, maxSpeed: number)
	local camCF = workspace.CurrentCamera.CFrame
	local flatLook = camCF.LookVector * Vector3.new(1, 0, 1)
	flatLook = flatLook.Unit.Magnitude > 0 and flatLook.Unit or Vector3.new(0, 0, -1)

	local camForward = flatLook.Unit
	local camRight = Vector3.new(-camForward.Z, 0, camForward.X)

	local worldMoveDir = (camRight * inputDirection.X + camForward * inputDirection.Y).Unit

	local speed = velocity.Magnitude
	local normalizedSpeed = math.clamp(speed / maxSpeed, 0, 1)

	local scaledMove = worldMoveDir * normalizedSpeed

	local moveX = camRight:Dot(scaledMove)
	local moveY = camForward:Dot(scaledMove)

	return Vector2.new(moveX, moveY)
end


-- Manter input clamped para dentro do círculo do blendtree:
-- velocity.Magnitude == speed
local inputVector = inputDirVector.Unit * math.clamp(speed / maxSpeed, 0, 1) -- walk, run
local inputVector = inputDirVector.Unit * math.clamp(speed / maxSpeed, 0, 2) -- walk, run, sprint
]]--
local BlendTree2D = {}
BlendTree2D.__index = BlendTree2D

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

function BlendTree2D.new(config)
	local self = setmetatable({}, BlendTree2D)
	self.rawInputVector = Vector2.zero
	self.inputVector = Vector2.zero
	self.maxSpeed = config.maxSpeed or 16
	self.lerpSpeed = config.lerpSpeed or 10
	self.weightThreshold = 0.05
	self.nodes = {}

	for _, node in ipairs(config.nodes) do
		table.insert(self.nodes, {
			position = node.position,
			track = node.track,
			weight = 0
		})

		node.track:Play()
		node.track:AdjustWeight(0)
	end

	return self
end

function BlendTree2D:Update(dt)
	self.inputVector = self.inputVector:Lerp(self.rawInputVector, dt * self.lerpSpeed)
	local weights = calculateBlendWeights(self.inputVector, self.nodes)

	for i, node in ipairs(self.nodes) do
		node.weight = math.lerp(node.weight, weights[i], dt * self.lerpSpeed)
		local adjustedWeight = (node.weight > self.weightThreshold) and node.weight or 0
		node.track:AdjustWeight(adjustedWeight)
	end
end

return BlendTree2D