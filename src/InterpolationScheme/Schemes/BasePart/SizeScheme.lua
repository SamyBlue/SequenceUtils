local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local NumSeqMap = require(script.Parent.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local SizeScheme = {}

SizeScheme.Attributes = {
    ["SizeFrom"] = Vector3.new(0, 0, 0), --* Coordinates must be specified in initial object space of relevant instance
    ["SizeStart"] = Vector3.new(1, 1, 1), --! All x, y, z Vector3 components assumed non-zero
    ["SizeGoal"] = Vector3.new(1, 1, 1), --! All x, y, z Vector3 components assumed non-zero
    ["SizeSequence"] = NumberSequence.new(1)
}

SizeScheme._LoopCondition = function (instance)
    return IsSequenceNotConstant(instance:GetAttribute("SizeSequence"))
end

SizeScheme.Setup = function (instance)
    --Setup Attributes
    for attribute, value in ipairs(SizeScheme.Attributes) do
        instance:SetAttribute(attribute, value)
    end
end

SizeScheme.Play = function (instance, timeLength, applyTo)
    
    if not SizeScheme._LoopCondition(instance) then
        return
    end

    applyTo = applyTo or instance -- (Optional) Specify an alternative instance to apply scheme to

    local SizeFrom = instance:GetAttribute("SizeFrom")
    
    local Start, Goal = instance:GetAttribute("SizeStart"), instance:GetAttribute("SizeGoal")
    local Diff = Goal - Start
    local SeqMap = NumSeqMap.new(instance:GetAttribute("SizeSequence"))

    if SizeFrom == Vector3.new(0, 0, 0) then
        HeartbeatLoopFor(timeLength, function (_, _, interp)
            applyTo.Size = Start + Diff * SeqMap:GetValue(interp)
        end, function ()
            applyTo.Size = Goal
        end)
    else        
        HeartbeatLoopFor(timeLength, function (_, _, interp)
            local scale = Start + Diff * SeqMap:GetValue(interp)
            applyTo.Position = applyTo.CFrame:PointToWorldSpace(SizeFrom - SizeFrom * scale)
            applyTo.Size = scale
        end, function ()
            applyTo.Size = Goal
        end)
    end

end

return SizeScheme