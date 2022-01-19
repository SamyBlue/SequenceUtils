local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local IntervalChangeDetector = require(script.Parent.Parent.Parent.SchemesUtil.IntervalChangeDetector)
local EmitSoundScheme = {}

EmitSoundScheme.Attributes = {
    ["EmitSoundSequence"] = NumberSequence.new(0)
}

EmitSoundScheme._InsertResetState = function (initialState, _, applyTo)
    if not initialState[applyTo] then
        initialState[applyTo] = {}
    end
end

EmitSoundScheme._LoopCondition = function (instance)
    return IsSequenceNotConstant(instance:GetAttribute("EmitSoundSequence"))
end

EmitSoundScheme.Setup = function (instance)
    --Setup Attributes
    for attribute, value in pairs(EmitSoundScheme.Attributes) do
        instance:SetAttribute(attribute, value)
    end
end

EmitSoundScheme.Play = function (instance, timeLength, applyTo)
    
    if not EmitSoundScheme._LoopCondition(instance) then
        return
    end

    applyTo = applyTo or instance -- (Optional) Specify an alternative instance to apply scheme to
    
    local Interval = IntervalChangeDetector.new(instance:GetAttribute("EmitSoundSequence"))

    HeartbeatLoopFor(timeLength, function (_, _, interp)
        Interval:TimeUpdate(interp)

        if Interval:PrevTimeUpdateChangedInterval() then
            local soundClone = applyTo:Clone()
            soundClone.PlayOnRemove = true
            soundClone.Parent = applyTo.Parent
            soundClone:Destroy()
        end
    end)

end

return EmitSoundScheme