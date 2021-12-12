local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local NumSeqMap = require(script.Parent.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local SizeScheme = {}

SizeScheme.Attributes = {
    ["SizeFrom"] = Vector3.new(0, 0, 0), --* Coordinates must be specified in initial object space of relevant instance
    ["SizeGoal"] = Vector3.new(1, 1, 1), --! All x, y, z Vector3 components assumed non-zero
    ["SizeSequence"] = NumberSequence.new(0),
    ["SizeChangesEmitters"] = false --* If want to scale all child attachment positions and any descendant particle emitters proportionally
}

--TODO: When SizeChangesEmitters is true, scale descendant beams proportionally too by changing CurveSize0, CurveSize1, Width0, Width1
SizeScheme._InsertResetState = function (initialState, instance, applyTo)
    initialState.CFrame = applyTo.CFrame
    initialState.Size = applyTo.Size

    local attachments
    local emitters

    if instance:GetAttribute("SizeChangesEmitters") == true then
        --TODO: Add reset logic for attachments and emitters
    end
end

SizeScheme._LoopCondition = function (instance)
    return IsSequenceNotConstant(instance:GetAttribute("SizeSequence"))
end

SizeScheme.Setup = function (instance)
    --Setup Attributes
    for attribute, value in pairs(SizeScheme.Attributes) do
        instance:SetAttribute(attribute, value)
    end
end

SizeScheme.Play = function (instance, timeLength, applyTo)
    
    if not SizeScheme._LoopCondition(instance) then
        return
    end

    applyTo = applyTo or instance -- (Optional) Specify an alternative instance to apply scheme to

    local SizeFrom = instance:GetAttribute("SizeFrom")
    
    local Initial, Goal = applyTo.Size, instance:GetAttribute("SizeGoal")
    local Diff = Goal - Initial
    local SeqMap = NumSeqMap.new(instance:GetAttribute("SizeSequence"), instance:GetAttribute("Keypoints"))

    if SizeFrom == Vector3.new(0, 0, 0) then

        HeartbeatLoopFor(timeLength, function (_, _, interp)
            applyTo.Size = Initial + Diff * SeqMap:GetValue(interp)
        end, function ()
            applyTo.Size = Initial + Diff * SeqMap:GetValue(1)
        end)

    else        

        local prevScale = Initial

        HeartbeatLoopFor(timeLength, function (_, _, interp)
            local scale = Initial + Diff * SeqMap:GetValue(interp)
            local scaleQuotient = scale / prevScale
            applyTo.Position = applyTo.CFrame:PointToWorldSpace(SizeFrom - SizeFrom * scaleQuotient)
            applyTo.Size = scale --? applyTo.Size * scaleQuotient if maybe want adaptive resizing in future
            SizeFrom = SizeFrom * scaleQuotient
            prevScale = scale
        end, function ()
            local scale = Initial + Diff * SeqMap:GetValue(1)
            local scaleQuotient = scale / prevScale
            applyTo.Position = applyTo.CFrame:PointToWorldSpace(SizeFrom - SizeFrom * scaleQuotient)
            applyTo.Size = scale --? applyTo.Size * scaleQuotient if maybe want adaptive resizing in future
        end)

    end

end

return SizeScheme