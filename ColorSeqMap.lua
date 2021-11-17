local ColorSeqMap = {} -- Define new class
ColorSeqMap.__type = "ColorSeqMap"
ColorSeqMap.__index = ColorSeqMap

function ColorSeqMap.new(colorSeq, mapSize)
	local self = setmetatable({}, ColorSeqMap)
	self._mapSize = mapSize or 20 -- must be an integer
	self._map = {}

	local keypoints = colorSeq.Keypoints

	if #keypoints == 2 then -- Special case where can construct map with 100% accuracy
		self._mapSize = 1
	end

	self._map[0] = keypoints[1].Value
	self._map[self._mapSize] = keypoints[#keypoints].Value

	self._samplingInterval = 1 / self._mapSize
	local kpointIndex = 2

	for i = 1, self._mapSize - 1 do
		local alphaTime = i * self._samplingInterval

		-- Get smallest keypoint.Time greater than alphaTime as an upperbound for interpolation
		if alphaTime > keypoints[kpointIndex].Time then
			for j = kpointIndex + 1, #keypoints do
				if alphaTime < keypoints[j].Time then
					kpointIndex = j
					break
				end
			end
		end

		-- Evaluate next point in map
		local nextKpoint = keypoints[kpointIndex]
		local prevKpoint = keypoints[kpointIndex - 1] -- lowerbound for interpolation

		self._map[i] = prevKpoint.Value + (nextKpoint.Value - prevKpoint.Value) * (alphaTime - prevKpoint.Time) / (nextKpoint.Time - prevKpoint.Time)
	end

	return self
end

-- Returns a linearly-approximated value on the ColorSequence near the point alpha
function ColorSeqMap:GetValue(alpha) -- Ensure alpha clamped between 0 and 1
	local prevMapIndex = math.floor(alpha * self._mapSize)
	local nextMapIndex = math.min(self._mapSize, prevMapIndex + 1)

	return self._map[prevMapIndex]:lerp(self._map[nextMapIndex], (alpha - prevMapIndex * self._samplingInterval) * self._mapSize)
end

return ColorSeqMap
