local GetSchemesFor = require(script.Parent.GetSchemesFor)

local function PlaySchemesOnInstance(instance)
    local TimeLength = instance:GetAttribute("TimeLength")
    local IsPlaying = instance:GetAttribute("IsPlaying")

    if IsPlaying == true then
        warn("Cannot play Schemes on a currently playing instance : " ..instance:GetFullName())
        return
    end

    instance:SetAttribute("IsPlaying", true)

    local Schemes, applyTo = GetSchemesFor(instance)

    if Schemes then
        for _, Scheme in pairs(Schemes) do
            Scheme.Play(instance, TimeLength, applyTo)
        end
    end
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