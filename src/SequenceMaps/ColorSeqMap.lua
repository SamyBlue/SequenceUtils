local ColorSeqMap = {} -- Define new class
ColorSeqMap.__type = "ColorSeqMap"
ColorSeqMap.__index = ColorSeqMap

-- Gamma is used to change the color space used for interpolation where higher gamma better preserves perceived brightness. See: https://www.youtube.com/watch?v=LKnqECcg6Gw
function ColorSeqMap.new(colorSeq, gamma, mapSize)
	local self = setmetatable({}, ColorSeqMap)
	self._mapSize = mapSize or 20 -- must be an integer
    self._gamma = gamma or 2
    self._gammaDiv = 1 / self._gamma
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

		self._map[i] = self:_interpColorExponent(prevKpoint.Value, nextKpoint.Value, (alphaTime - prevKpoint.Time) / (nextKpoint.Time - prevKpoint.Time))
	end

	return self
end

function ColorSeqMap:_interpColorExponent(startColor, endColor, fraction) -- Interpolate with gamma correction in exponentiated space
    local gamma = self._gamma
    local sColor = Color3.new(startColor.R ^ gamma, startColor.G ^ gamma, startColor.B ^ gamma)
    local eColor = Color3.new(endColor.R ^ gamma, endColor.G ^ gamma, endColor.B ^ gamma)
    local interpolated = sColor:Lerp(eColor, fraction)
    return interpolated
end

function ColorSeqMap:_interpColor(startColor, endColor, fraction) -- Interpolate and bring out of exponentiated space
    local gammaDiv = self._gammaDiv
    local interpolated = startColor:Lerp(endColor, fraction)
    return Color3.new(interpolated.R ^ gammaDiv, interpolated.G ^ gammaDiv, interpolated.B ^ gammaDiv)
end

-- Returns a linearly-approximated value on the ColorSequence near the point alpha
function ColorSeqMap:GetValue(alpha) -- Ensure alpha clamped between 0 and 1
	local prevMapIndex = math.floor(alpha * self._mapSize)
	local nextMapIndex = math.min(self._mapSize, prevMapIndex + 1)

	return self:_interpColor(self._map[prevMapIndex], self._map[nextMapIndex], (alpha - prevMapIndex * self._samplingInterval) * self._mapSize)
end

return ColorSeqMap
