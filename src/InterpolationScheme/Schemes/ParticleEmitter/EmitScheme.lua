local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local IntervalChangeDetector = require(script.Parent.Parent.Parent.SchemesUtil.IntervalChangeDetector)
local EmitScheme = {}

EmitScheme.Attributes = {
    ["EmitMaxAmount"] = 0,
    ["EmitSequence"] = NumberSequence.new(0)
}

EmitScheme._InsertResetState = function (initialState, _, applyTo)
    if not initialState[applyTo] then
        initialState[applyTo] = {}
    end
end

EmitScheme._LoopCondition = function (instance)
    return IsSequenceNotConstant(instance:GetAttribute("EmitSequence"))
end

EmitScheme.Setup = function (instance)
    --Setup Attributes
    for attribute, value in pairs(EmitScheme.Attributes) do
        instance:SetAttribute(attribute, value)
    end
end

EmitScheme.Play = function (instance, timeLength, applyTo)
    
    if not EmitScheme._LoopCondition(instance) then
        return
    end

    applyTo = applyTo or instance -- (Optional) Specify an alternative instance to apply scheme to
    
    local EmitMax = instance:GetAttribute("EmitMaxAmoujnt")
    local Interval = IntervalChangeDetector.new(instance:GetAttribute("EmitSequence"))

    HeartbeatLoopFor(timeLength, function (_, _, interp)
        Interval:TimeUpdate(interp)

        if Interval:PrevTimeUpdateChangedInterval() then
            applyTo:Emit(Interval.lowerKeypoint.Value * EmitMax)
        end
    end)

end

return EmitScheme