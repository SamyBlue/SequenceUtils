local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local NumSeqMap = require(script.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local SizeScheme = {}

SizeScheme.Attributes = {
    ["SizeFrom"] = Vector3.new(0, 0, 0),
    ["SizeMin"] = Vector3.new(10, 10, 10),
    ["SizeMax"] = Vector3.new(10, 10, 10),
    ["SizeSequence"] = NumberSequence.new(1)
}

SizeScheme.LoopCondition = function (instance)
    return #instance:GetAttribute("SizeSequence").Keypoints > 1
end


SizeScheme.Constructor = function (instance, timeLength)
    
    if not SizeScheme.LoopCondition(instance) then
        return
    end

    local SizeFrom = instance:GetAttribute("SizeFrom") --TODO: Add SizeFrom Positioning Logic
    
    local Min, Max = instance:GetAttribute("SizeMin"), instance:GetAttribute("SizeMax")
    local Diff = Max - Min
    local Sequence = instance:GetAttribute("SizeSequence")
    local SeqMap = NumSeqMap.new(Sequence)

    HeartbeatLoopFor(timeLength, function (_, _, interp)
        instance.Size = Min + Diff * SeqMap:GetValue(interp)
    end, function ()
        instance.Size = Max
    end)

end


return SizeScheme