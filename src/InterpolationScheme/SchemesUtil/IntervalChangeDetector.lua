-- Efficiently tells you when some updating time-value moves past the time-interval that it sits within (between two consecutive keypoints) within a NumberSequence or ColorSequence

local IntervalChangeDetector = {} -- Define new class
IntervalChangeDetector.__type = "IntervalChangeDetector"
IntervalChangeDetector.__index = IntervalChangeDetector

function IntervalChangeDetector.new(sequenceObject)
	local self = setmetatable({}, IntervalChangeDetector)

	self._keypoints = sequenceObject.Keypoints
	self._numKeypoints = #self._keypoints
	self._lastLowerKeypointIndex = 1

	self.lowerKeypointIndex = 1
	self.lowerKeypoint = self._keypoints[self.lowerKeypointIndex]

	return self
end

--* Assumes: Each UpdateTime(timeInput) uses a timeInput value that is greater than (or equal to) the most previously used timeInput value for this function prior
--* i.e. consecutive calls of UpdateTime must have ascending timeInputs
function IntervalChangeDetector:TimeUpdate(timeInput) --TODO: Add warning if timeInput given is less than previous timeInput
	self._lastLowerKeypointIndex = self.lowerKeypointIndex

	for i = self._numKeypoints - 1, self.lowerKeypointIndex + 1, -1 do
		local keypoint = self._keypoints[i]
		if timeInput > keypoint.Time then -- interval changed
			self.lowerKeypointIndex = i
			self.lowerKeypoint = keypoint
			break
		end
	end
end

-- Returns true if the most recently updated time value changed from its last time-interval to a new time-interval with different lowerKeypointTime and upperKeypointTime
-- false otherwise
function IntervalChangeDetector:PrevTimeUpdateChangedInterval() --> boolean
	return self._lastLowerKeypointIndex ~= self.lowerKeypointIndex
end

return IntervalChangeDetector