local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.IsSequenceNotConstant)
local NumSeqMap = require(script.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local SizeScheme = {}

SizeScheme.Attributes = {
    ["SizeFrom"] = Vector3.new(0, 0, 0),
    ["SizeMin"] = Vector3.new(1, 1, 1),
    ["SizeMax"] = Vector3.new(1, 1, 1),
    ["SizeSequence"] = NumberSequence.new(1)
}

SizeScheme.LoopCondition = function (instance)
    return IsSequenceNotConstant(#instance:GetAttribute("SizeSequence"))
end


SizeScheme.Constructor = function (instance, timeLength)
    
    if not SizeScheme.LoopCondition(instance) then
        return
    end

    local SizeFrom = instance:GetAttribute("SizeFrom")
    local SizeFromWorldPos = instance.CFrame:PointToWorldSpace(SizeFrom)
    local OffsetVector = instance.Position - SizeFromWorldPos
    
    local Min, Max = instance:GetAttribute("SizeMin"), instance:GetAttribute("SizeMax")
    local Diff = Max - Min
    local SeqMap = NumSeqMap.new(instance:GetAttribute("SizeSequence"))

    HeartbeatLoopFor(timeLength, function (_, _, interp)
        instance.Size = Min + Diff * SeqMap:GetValue(interp)
    end, function ()
        instance.Size = Max
    end)

end


return SizeScheme