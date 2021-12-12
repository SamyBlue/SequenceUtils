local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local NumSeqMap = require(script.Parent.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local SizeScheme = {}

SizeScheme.Attributes = {
    ["SizeFrom"] = Vector3.new(0, 0, 0), --* Coordinates must be specified in initial object space of relevant instance
    ["SizeGoal"] = Vector3.new(1, 1, 1), --! All x, y, z Vector3 components assumed non-zero
    ["SizeSequence"] = NumberSequence.new(0),
    ["SizeScalesAttachments"] = false, --* If want to scale all descendant attachment positions proportionally
    ["SizeScalesEmitters"] = false --* If want to scale all descendant particle emitters proportionally
} --TODO: SizeScalesBeams

SizeScheme._InsertResetState = function (initialState, instance, applyTo)
    if not initialState[applyTo] then
        initialState[applyTo] = {}
    end
    local applyToState = initialState[applyTo]

    applyToState.CFrame = applyTo.CFrame
    applyToState.Size = applyTo.Size

    local SizeScalesAttachments = instance:GetAttribute("SizeScalesAttachments")
    local SizeScalesEmitters = instance:GetAttribute("SizeScalesEmitters")

    if SizeScalesAttachments or SizeScalesEmitters then
        for _, obj in ipairs(applyTo:GetDescendants()) do
            if obj.ClassName == "Attachment" and SizeScalesAttachments then
                
                if not initialState[obj] then
                    initialState[obj] = {}
                end
                local objState = initialState[obj]

                objState.CFrame = obj.CFrame

            elseif obj.ClassName == "ParticleEmitter" and SizeScalesEmitters then
                
                if not initialState[obj] then
                    initialState[obj] = {}
                end
                local objState = initialState[obj]

                objState.Size = obj.Size
                objState.Speed = obj.Speed

            end
        end
    end
end

SizeScheme._LoopCondition = function (instance)
    return IsSequenceNotConstant(instance:GetAttribute("SizeSequence"))
end

local function ScaleParticle(particle, scale)		
	local newKeypoints = {}
	local keypoints = particle.Size.Keypoints
	for index, kp in ipairs(keypoints) do
		newKeypoints[index] = NumberSequenceKeypoint.new(kp.Time, kp.Value * scale, kp.Envelope * scale)
	end

	particle.Size = NumberSequence.new(newKeypoints)
	particle.Speed = NumberRange.new(particle.Speed.Min * scale, particle.Speed.Max * scale)
    --TODO: Scale Acceleration and Drag
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
    local SizeScalesAttachments = instance:GetAttribute("SizeScalesAttachments")
    local SizeScalesEmitters = instance:GetAttribute("SizeScalesEmitters")

    local attachments = {}
    local emitters = {}
    if SizeScalesAttachments or SizeScalesEmitters then
        for _, obj in ipairs(applyTo:GetDescendants()) do
            if obj.ClassName == "Attachment" and SizeScalesAttachments then
                table.insert(attachments, obj)
            elseif obj.ClassName == "ParticleEmitter" and SizeScalesEmitters then
                table.insert(emitters, obj)
            end
        end
    end

    local ScaleAttachments = function (scaleQuotient)
        for _, attachment in ipairs(attachments) do
            attachment.Position = attachment.Position * scaleQuotient
        end
    end

    local ScaleEmitters = function (scaleQuotient)
        scaleQuotient = math.max(scaleQuotient.X, scaleQuotient.Y, scaleQuotient.Z)
        for _, emitter in ipairs(emitters) do
            ScaleParticle(emitter, scaleQuotient)
        end
    end

    local Initial, Goal = applyTo.Size, instance:GetAttribute("SizeGoal")
    local Diff = Goal - Initial
    local SeqMap = NumSeqMap.new(instance:GetAttribute("SizeSequence"), instance:GetAttribute("Keypoints"))

    local prevScale = Initial

    if SizeFrom == Vector3.new(0, 0, 0) then

        HeartbeatLoopFor(timeLength, function (_, _, interp)
            local scale = Initial + Diff * SeqMap:GetValue(interp)
            local scaleQuotient = scale / prevScale
            applyTo.Size = scale --? applyTo.Size * scaleQuotient if maybe want adaptive resizing in future
            ScaleAttachments(scaleQuotient)
            ScaleEmitters(scaleQuotient)
            prevScale = scale
        end, function ()
            local scale = Initial + Diff * SeqMap:GetValue(1)
            local scaleQuotient = scale / prevScale
            applyTo.Size = scale --? applyTo.Size * scaleQuotient if maybe want adaptive resizing in future
            ScaleAttachments(scaleQuotient)
            ScaleEmitters(scaleQuotient)

        end)

    else        

        HeartbeatLoopFor(timeLength, function (_, _, interp)
            local scale = Initial + Diff * SeqMap:GetValue(interp)
            local scaleQuotient = scale / prevScale
            applyTo.Position = applyTo.CFrame:PointToWorldSpace(SizeFrom - SizeFrom * scaleQuotient)
            applyTo.Size = scale --? applyTo.Size * scaleQuotient if maybe want adaptive resizing in future
            SizeFrom = SizeFrom * scaleQuotient
            ScaleAttachments(scaleQuotient)
            ScaleEmitters(scaleQuotient)
            prevScale = scale
        end, function ()
            local scale = Initial + Diff * SeqMap:GetValue(1)
            local scaleQuotient = scale / prevScale
            applyTo.Position = applyTo.CFrame:PointToWorldSpace(SizeFrom - SizeFrom * scaleQuotient)
            applyTo.Size = scale --? applyTo.Size * scaleQuotient if maybe want adaptive resizing in future
            ScaleAttachments(scaleQuotient)
            ScaleEmitters(scaleQuotient)
        end)

    end

end

return SizeScheme