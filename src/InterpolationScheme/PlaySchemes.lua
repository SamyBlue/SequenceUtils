local SchemesFolder = script.Parent.Schemes
local Schemes = {}  --TODO: Turn into a module script "package" and just require in future

for _, ClassFolder in ipairs(SchemesFolder:GetChildren()) do
    local contains = {}

    for _, Scheme in ipairs(ClassFolder:GetChildren()) do
        contains[Scheme.Name] = require(Scheme)
    end

    Schemes[ClassFolder.Name] = contains
end

local function PlaySchemesOnInstance(instance)
    local TimeLength = instance:GetAttribute("TimeLength")

    if instance:IsA('BasePart') then
        for _, Scheme in ipairs(Schemes.BasePart) do
            Scheme.Play(instance, TimeLength)
        end
    end --TODO: Add cases for particle emitters + other classes
end

local function PlaySchemes(instanceOrArray)
    if typeof(instanceOrArray) == "Instance" then
        PlaySchemesOnInstance(instanceOrArray)
    elseif typeof(instanceOrArray) == "table" then
        for _, instance in ipairs(instanceOrArray) do
            if instance:GetAttribute("TimeLength") ~= nil then -- Find instances that were setup with an interpolation scheme
                PlaySchemesOnInstance(instance)
            end
        end
    end
end

return PlaySchemes