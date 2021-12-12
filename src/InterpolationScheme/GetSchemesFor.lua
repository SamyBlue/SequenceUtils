local SchemesFolder = script.Parent.Schemes
local Schemes = {}

for _, ClassFolder in ipairs(SchemesFolder:GetChildren()) do
    local contains = {}

    for _, Scheme in ipairs(ClassFolder:GetChildren()) do
        contains[Scheme.Name] = require(Scheme)
    end

    Schemes[ClassFolder.Name] = contains
end

--Returns an array of all interpolation scheme modules that can interact with a given instance
local function GetSchemesFor(instance)
    local applyTo

    if instance:IsA('BasePart') then
        applyTo = instance
        return Schemes.BasePart, applyTo
    elseif Schemes[instance.ClassName] ~= nil then
        applyTo = instance
        return Schemes[instance.ClassName], applyTo
    elseif instance.ClassName == "Configuration" and Schemes[instance.Name] then
        applyTo = instance.Parent
        return Schemes[instance.Name], applyTo
    end
end

return GetSchemesFor