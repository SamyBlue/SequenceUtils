local NumSeqMap = {} -- Define new class
NumSeqMap.__type = "NumSeqMap"
NumSeqMap.__index = NumSeqMap

-- Stores a NumberSequence as a mapping array for efficient O(1) reads
-- specifying mapSize is optional and represents the number of equally-spaced samples taken to accurately represent the number sequence in map format
function NumSeqMap.new(numSeq, mapSize)
	local self = setmetatable({}, NumSeqMap)
	self._mapSize = mapSize or 20 -- must be an integer
	self._map = {}

	local keypoints = numSeq.Keypoints

	if #keypoints == 2 then -- Special case where can construct map with 100% accuracy
		self._mapSize = 1
	end

	self._map[0] = keypoints[1].Value
	self._map[self._mapSize] = keypoints[#keypoints].Value

	self._samplingInterval = 1 / self._mapSize
	local kpointIndex = 2

	for i = 1, self._mapSize - 1 do
		local alphaTime = i * self._samplingInterval

		--Get smallest keypoint.Time greater than alphaTime
		if alphaTime > keypoints[kpointIndex].Time then
			for j = kpointIndex + 1, #keypoints do
				if alphaTime < keypoints[j].Time then
					kpointIndex = j
					break
				end
			end
		end

		local kpointTime = keypoints[kpointIndex].Time
		local prevKpointTime = keypoints[kpointIndex - 1].Time
		local kpointValue = keypoints[kpointIndex].Value
		local prevKpointValue = keypoints[kpointIndex - 1].Value

		self._map[i] = prevKpointValue + (kpointValue - prevKpointValue) * (alphaTime - prevKpointTime) / (kpointTime - prevKpointTime)
	end

	return self
end

-- Returns a linearly-approximated value on the NumberSequence near the point alpha
function NumSeqMap:GetValue(alpha) -- alpha clamped between 0 and 1
	-- return self._map[math.floor(math.clamp(alpha, 0, 1) * self._mapSize)]
end

return NumSeqMap
