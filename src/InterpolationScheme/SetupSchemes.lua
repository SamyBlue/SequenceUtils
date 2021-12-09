local SchemesFolder = script.Parent.Schemes
local Schemes = {}  --TODO: Turn into a module script "package" and just require in future

for _, ClassFolder in ipairs(SchemesFolder:GetChildren()) do
    local contains = {}

    for _, Scheme in ipairs(ClassFolder) do
        contains[Scheme.Name] = require(Scheme)
    end

    Schemes[ClassFolder.Name] = contains
end

local function SetupSchemesOnInstance(instance)
    local TimeLength = instance:GetAttribute("TimeLength")

    if instance:IsA('BasePart') then
        for _, Scheme in ipairs(Schemes.BasePart) do
            Scheme.Setup(instance)
        end
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