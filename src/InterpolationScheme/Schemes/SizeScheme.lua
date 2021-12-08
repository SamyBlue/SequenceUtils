local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.IsSequenceNotConstant)
local NumSeqMap = require(script.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local SizeScheme = {}

SizeScheme.Attributes = {
    ["SizeFrom"] = Vector3.new(0, 0, 0), --* Coordinates must be specified in initial object space of relevant instance
    ["SizeMin"] = Vector3.new(1, 1, 1), --! All x, y, z Vector3 components assumed non-zero
    ["SizeMax"] = Vector3.new(1, 1, 1), --! All x, y, z Vector3 components assumed non-zero
    ["SizeSequence"] = NumberSequence.new(1)
}

SizeScheme._LoopCondition = function (instance)
    return IsSequenceNotConstant(instance:GetAttribute("SizeSequence"))
end

SizeScheme.Constructor = function (instance, timeLength, applyTo)
    
    if not SizeScheme._LoopCondition(instance) then
        return
    end

    applyTo = applyTo or instance -- (Optional) Specify an alternative instance to apply scheme to

    local SizeFrom = instance:GetAttribute("SizeFrom")
    
    local Min, Max = instance:GetAttribute("SizeMin"), instance:GetAttribute("SizeMax")
    local Diff = Max - Min
    local SeqMap = NumSeqMap.new(instance:GetAttribute("SizeSequence"))

    if SizeFrom == Vector3.new(0, 0, 0) then
        HeartbeatLoopFor(timeLength, function (_, _, interp)
            applyTo.Size = Min + Diff * SeqMap:GetValue(interp)
        end, function ()
            applyTo.Size = Max
        end)
    else        
        HeartbeatLoopFor(timeLength, function (_, _, interp)
            local scale = Min + Diff * SeqMap:GetValue(interp)
            applyTo.Position = applyTo.CFrame:PointToWorldSpace(SizeFrom - SizeFrom * scale)
            applyTo.Size = scale
        end, function ()
            applyTo.Size = Max
        end)
    end

end

return SizeScheme