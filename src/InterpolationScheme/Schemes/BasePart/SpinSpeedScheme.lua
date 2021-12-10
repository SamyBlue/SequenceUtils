local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local NumSeqMap = require(script.Parent.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local SpinSpeedScheme = {}

SpinSpeedScheme.Attributes = {
    ["SpinAxis"] = Vector3.new(0, 1, 0), --* Coordinates must be specified in object space of relevant instance
    ["SpinSpeedInitial"] = 0,
    ["SpinSpeedGoal"] = 0,
    ["SpinSpeedSequence"] = NumberSequence.new(0)
}

SpinSpeedScheme._LoopCondition = function (instance)
    return instance:GetAttribute("SpinSpeedInitial") ~= 0 or instance:GetAttribute("SpinSpeedGoal") ~= 0
end

SpinSpeedScheme.Setup = function (instance)
    --Setup Attributes
    for attribute, value in pairs(SpinSpeedScheme.Attributes) do
        instance:SetAttribute(attribute, value)
    end
end

SpinSpeedScheme.Play = function (instance, timeLength, applyTo)
    
    if not SpinSpeedScheme._LoopCondition(instance) then
        return
    end

    applyTo = applyTo or instance -- (Optional) Specify an alternative instance to apply scheme to
    
    local Initial, Goal = applyTo:GetAttribute("SpinSpeedInitial"), instance:GetAttribute("SpinSpeedGoal")
    local Diff = Goal - Initial
    local SeqMap = NumSeqMap.new(instance:GetAttribute("SpinSpeedSequence"), instance:GetAttribute("Keypoints"))

    local SpinAxis = instance:GetAttribute("SpinAxis").Unit

    HeartbeatLoopFor(timeLength, function (_, dt, interp)
        applyTo.CFrame = applyTo.CFrame * CFrame.fromAxisAngle(SpinAxis, dt * (Initial + Diff * SeqMap:GetValue(interp)))
    end, function ()
        applyTo.CFrame = applyTo.CFrame * CFrame.fromAxisAngle(SpinAxis, (1/60) * (Initial + Diff * SeqMap:GetValue(1)))
    end)

end

return SpinSpeedScheme