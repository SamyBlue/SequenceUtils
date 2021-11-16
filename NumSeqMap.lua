local NumSeqMap = {} -- Define new class
NumSeqMap.__type = "NumSeqMap"
NumSeqMap.__index = NumSeqMap

-- Stores a NumberSequence as a mapping array for efficient O(1) reads
-- specifying mapSize is optional and represents the number of equally-spaced samples taken to accurately represent the number sequence in map format
function NumSeqMap.new(numSeq, mapSize) --TODO: Change to maxMapSize where mapSize adapts to number of keypoints? Special case when #keypoints = 2
	local self = setmetatable({}, NumSeqMap)
	self._mapSize = mapSize or 20 -- must be an integer
	self._map = {}
	
	local SAMPLING_INTERVAL = 1 / self._mapSize
	local keypoints = numSeq.Keypoints
	
	self._map[0] = keypoints[1].Value
	self._map[self._mapSize] = keypoints[#keypoints].Value
	
	local kpointIndex = 2
	
	for i = 1, self._mapSize - 1 do
		
		local kpointTime = keypoints[kpointIndex].Time
		
		local alpha = i * SAMPLING_INTERVAL
		
	end

	return self
end

-- Returns a linearly-approximated value on the NumberSequence near the point alpha
function NumSeqMap:GetValue(alpha) -- alpha clamped between 0 and 1
	-- return self._map[math.floor(math.clamp(alpha, 0, 1) * self._mapSize)]
end

return NumSeqMap