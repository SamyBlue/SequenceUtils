--* Must have a BasePart as Parent
--* Helps more easily create acceleration versus using the gradient of a SpeedSequence
local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local NumSeqMap = require(script.Parent.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local AccelerationScheme = {}

AccelerationScheme.Attributes = {
    ["AccelerationDirection"] = Vector3.new(0, -1, 0), --* Coordinates must be specified in world space
    ["AccelerationInitial"] = 0,
    ["AccelerationGoal"] = 0,
    ["AccelerationSequence"] = NumberSequence.new(0),
    ["InitialObjectVelocity"] = Vector3.new(0, 0, 0), --* Coordinates must be specified in initial object space
}

AccelerationScheme._InsertResetState = function (initialState, _, applyTo)
    if not initialState[applyTo] then
        initialState[applyTo] = {}
    end
    local applyToState = initialState[applyTo]
    applyToState.CFrame = applyTo.CFrame
end

AccelerationScheme._LoopCondition = function (instance)
    return instance:GetAttribute("AccelerationInitial") ~= 0 or instance:GetAttribute("AccelerationGoal") ~= 0 or instance:GetAttribute("InitialObjectVelocity") ~= Vector3.new(0, 0, 0)
end

AccelerationScheme.Setup = function (instance)
    --Setup Attributes
    for attribute, value in pairs(AccelerationScheme.Attributes) do
        instance:SetAttribute(attribute, value)
    end
end

AccelerationScheme.Play = function (instance, timeLength, applyTo)
    
    if not AccelerationScheme._LoopCondition(instance) then
        return
    end

    applyTo = applyTo or instance -- (Optional) Specify an alternative instance to apply scheme to
    
    local Initial, Goal = instance:GetAttribute("AccelerationInitial"), instance:GetAttribute("AccelerationGoal")
    local Diff = Goal - Initial
    local SeqMap = NumSeqMap.new(instance:GetAttribute("AccelerationSequence"), instance:GetAttribute("Keypoints"))

    local AccelerationDirection = instance:GetAttribute("AccelerationDirection").Unit
    local Velocity = applyTo.CFrame:VectorToWorldSpace(instance:GetAttribute("InitialObjectVelocity")) -- Initialize Velocity

    HeartbeatLoopFor(timeLength, function (_, dt, interp) -- Uses semi-implicit euler method
        Velocity = Velocity + AccelerationDirection * dt * (Initial + Diff * SeqMap:GetValue(interp))
        applyTo.Position = applyTo.Position + Velocity * dt
    end, function ()
        local dt = 1 / 60
        Velocity = Velocity + AccelerationDirection * dt * (Initial + Diff * SeqMap:GetValue(1))
        applyTo.Position = applyTo.Position + Velocity * dt
    end)

end

return AccelerationScheme