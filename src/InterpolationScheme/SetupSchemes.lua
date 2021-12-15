local GetSchemesFor = require(script.Parent.GetSchemesFor)
local DEFAULT_TIME_LENGTH = 1

local function SetupSchemesOnInstance(instance)
    if instance:GetAttribute("TimeLength") then
        warn("Resetting InterpolationScheme attributes for " .. instance:GetFullName())
    end

    instance:SetAttribute("TimeLength", DEFAULT_TIME_LENGTH)
    instance:SetAttribute("IsPlaying", false)
    instance:SetAttribute("Keypoints", 20)
    instance:SetAttribute("DelayBeforePlay", 0)

    local Schemes = GetSchemesFor(instance)

    if Schemes then
        for _, Scheme in pairs(Schemes) do
            Scheme.Setup(instance)
        end
    else -- No valid class found
        instance:SetAttribute("TimeLength", nil)
        instance:SetAttribute("IsPlaying", nil)
        instance:SetAttribute("Keypoints", nil)
        instance:SetAttribute("DelayBeforePlay", nil)
    end
end

local function SetupSchemes(instanceOrArray)
    if typeof(instanceOrArray) == "Instance" then
        SetupSchemesOnInstance(instanceOrArray)
    elseif typeof(instanceOrArray) == "table" then
        for _, instance in ipairs(instanceOrArray) do
            SetupSchemesOnInstance(instance)
        end
    end
end

return SetupSchemes