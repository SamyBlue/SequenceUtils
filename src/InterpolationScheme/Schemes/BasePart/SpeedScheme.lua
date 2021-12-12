local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local NumSeqMap = require(script.Parent.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local SpeedScheme = {}

SpeedScheme.Attributes = {
    ["SpeedDirection"] = Vector3.new(0, 1, 0), --* Coordinates must be specified in object space of relevant instance
    ["SpeedInitial"] = 0,
    ["SpeedGoal"] = 0,
    ["SpeedSequence"] = NumberSequence.new(0)
}

SpeedScheme._InsertResetState = function (initialState, _, applyTo)
    if not initialState[applyTo] then
        initialState[applyTo] = {}
    end
    local applyToState = initialState[applyTo]
    applyToState.CFrame = applyTo.CFrame
end

SpeedScheme._LoopCondition = function (instance)
    return instance:GetAttribute("SpeedInitial") ~= 0 or instance:GetAttribute("SpeedGoal") ~= 0
end

SpeedScheme.Setup = function (instance)
    --Setup Attributes
    for attribute, value in pairs(SpeedScheme.Attributes) do
        instance:SetAttribute(attribute, value)
    end
end

SpeedScheme.Play = function (instance, timeLength, applyTo)
    
    if not SpeedScheme._LoopCondition(instance) then
        return
    end

    applyTo = applyTo or instance -- (Optional) Specify an alternative instance to apply scheme to
    
    local Initial, Goal = instance:GetAttribute("SpeedInitial"), instance:GetAttribute("SpeedGoal")
    local Diff = Goal - Initial
    local SeqMap = NumSeqMap.new(instance:GetAttribute("SpeedSequence"), instance:GetAttribute("Keypoints"))

    local SpeedDirection = instance:GetAttribute("SpeedDirection").Unit

    HeartbeatLoopFor(timeLength, function (_, dt, interp)
        applyTo.CFrame = applyTo.CFrame * CFrame.new(SpeedDirection * dt * (Initial + Diff * SeqMap:GetValue(interp)))
    end, function ()
        applyTo.CFrame = applyTo.CFrame * CFrame.new(SpeedDirection * (1/60) * (Initial + Diff * SeqMap:GetValue(1)))
    end)

end

return SpeedScheme