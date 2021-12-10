local SchemesFolder = script.Parent.Schemes
local Schemes = {}  --TODO: Turn into a module script "package" and just require in future

local DEFAULT_TIME_LENGTH = 1

for _, ClassFolder in ipairs(SchemesFolder:GetChildren()) do
    local contains = {}

    for _, Scheme in ipairs(ClassFolder:GetChildren()) do
        contains[Scheme.Name] = require(Scheme)
    end

    Schemes[ClassFolder.Name] = contains
end

local function SetupSchemesOnInstance(instance)
    if instance:GetAttribute("TimeLength") then
        warn("Resetting InterpolationScheme attributes for " .. instance:GetFullName())
    end

    instance:SetAttribute("TimeLength", DEFAULT_TIME_LENGTH)
    instance:SetAttribute("IsPlaying", false)

    if instance:IsA('BasePart') then
        for _, Scheme in pairs(Schemes.BasePart) do
            Scheme.Setup(instance)
        end
    else -- No valid class found
        instance:SetAttribute("TimeLength", nil)
        instance:SetAttribute("IsPlaying", nil)
    end --TODO: Add cases for particle emitters + other classes
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