local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local NumSeqMap = require(script.Parent.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local TransparencyScheme = {}

TransparencyScheme.Attributes = {
    ["TransparencyGoal"] = 1,
    ["TransparencySequence"] = NumberSequence.new(0)
}

TransparencyScheme._LoopCondition = function (instance)
    return IsSequenceNotConstant(instance:GetAttribute("TransparencySequence"))
end

TransparencyScheme.Setup = function (instance)
    --Setup Attributes
    for attribute, value in pairs(TransparencyScheme.Attributes) do
        instance:SetAttribute(attribute, value)
    end
end

TransparencyScheme.Play = function (instance, timeLength, applyTo)
    
    if not TransparencyScheme._LoopCondition(instance) then
        return
    end

    applyTo = applyTo or instance -- (Optional) Specify an alternative instance to apply scheme to
    
    local Initial, Goal = applyTo.Transparency, instance:GetAttribute("TransparencyGoal")
    local Diff = Goal - Initial
    local SeqMap = NumSeqMap.new(instance:GetAttribute("TransparencySequence"), instance:GetAttribute("Keypoints"))

    HeartbeatLoopFor(timeLength, function (_, _, interp)
        applyTo.Transparency = Initial + Diff * SeqMap:GetValue(interp)
    end, function ()
        applyTo.Transparency = Initial + Diff * SeqMap:GetValue(1)
    end)

end

return TransparencyScheme