local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local ColorSeqMap = require(script.Parent.Parent.Parent.Parent.SequenceMaps.ColorSeqMap)
local ColorScheme = {}

ColorScheme.Attributes = {
    ["ColorSequence"] = ColorSequence.new(Color3.new())
}

ColorScheme._LoopCondition = function (instance)
    return IsSequenceNotConstant(instance:GetAttribute("ColorSequence"))
end

ColorScheme.Setup = function (instance)
    --Setup Attributes
    for attribute, value in pairs(ColorScheme.Attributes) do
        instance:SetAttribute(attribute, value)
    end
end

ColorScheme.Play = function (instance, timeLength, applyTo)
    
    if not ColorScheme._LoopCondition(instance) then
        return
    end

    applyTo = applyTo or instance -- (Optional) Specify an alternative instance to apply scheme to
    
    local SeqMap = ColorSeqMap.new(instance:GetAttribute("ColorSequence"))

    HeartbeatLoopFor(timeLength, function (_, _, interp)
        applyTo.Color = SeqMap:GetValue(interp)
    end, function ()
        applyTo.Color = SeqMap:GetValue(1)
    end)

end

return ColorScheme