local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local IntervalChangeDetector = require(script.Parent.Parent.Parent.SchemesUtil.IntervalChangeDetector)
local EnabledScheme = {}

EnabledScheme.Attributes = {
    ["EnabledSequence"] = NumberSequence.new(0.5)
}

EnabledScheme._InsertResetState = function (initialState, _, applyTo)
    if not initialState[applyTo] then
        initialState[applyTo] = {}
    end
    local applyToState = initialState[applyTo]
    applyToState.Enabled = applyTo.Enabled
end

EnabledScheme._LoopCondition = function (instance)
    return IsSequenceNotConstant(instance:GetAttribute("EnabledSequence"))
end

EnabledScheme.Setup = function (instance)
    --Setup Attributes
    for attribute, value in pairs(EnabledScheme.Attributes) do
        instance:SetAttribute(attribute, value)
    end
end

EnabledScheme.Play = function (instance, timeLength, applyTo)
    
    if not EnabledScheme._LoopCondition(instance) then
        return
    end

    applyTo = applyTo or instance -- (Optional) Specify an alternative instance to apply scheme to
    
    local Interval = IntervalChangeDetector.new(instance:GetAttribute("EnabledSequence"))

    HeartbeatLoopFor(timeLength, function (_, _, interp)
        Interval:TimeUpdate(interp)

        if Interval:PrevTimeUpdateChangedInterval() then
            applyTo.Enabled = Interval.lowerKeypoint.Value > 0.5
        end
    end)

end

return EnabledScheme