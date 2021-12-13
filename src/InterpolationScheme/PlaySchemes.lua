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

-- Plays schemes for a supplied instance or array of instances and returns the max. amount of time taken for all instances to finish playing
local function PlaySchemes(instanceOrArray)
    if typeof(instanceOrArray) == "Instance" then
        PlaySchemesOnInstance(instanceOrArray)

        return instanceOrArray:GetAttribute("TimeLength")
    elseif typeof(instanceOrArray) == "table" then
        local MaxTimeLength = 0

        for _, instance in ipairs(instanceOrArray) do
            local timeLength = instance:GetAttribute("TimeLength")
            if timeLength ~= nil then -- Find instances that were setup with an interpolation scheme
                PlaySchemesOnInstance(instance)

                if timeLength > MaxTimeLength then
                    MaxTimeLength = timeLength
                end
            end
        end

        return MaxTimeLength
    end
end

return PlaySchemes