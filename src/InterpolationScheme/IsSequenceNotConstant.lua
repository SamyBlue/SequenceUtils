local function IsSequenceNotConstant(Sequence) -- returns true if a number sequence or color sequence is not a constant value, false otherwise
    return #Sequence.Keypoints > 2 or Sequence.Keypoints[1].Value ~= Sequence.Keypoints[2].Value
end

return IsSequenceNotConstant