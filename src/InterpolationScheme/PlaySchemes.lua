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
        local delayBeforePlay = instance:GetAttribute("DelayBeforePlay")
        if delayBeforePlay == 0 then
            for _, Scheme in pairs(Schemes) do
                Scheme.Play(instance, TimeLength, applyTo)
            end
        else
            task.spawn(function ()
                task.wait(delayBeforePlay)
                for _, Scheme in pairs(Schemes) do
                    Scheme.Play(instance, TimeLength, applyTo)
                end
            end)
        end
    end
end

-- Plays schemes for a supplied instance or array of instances and returns the max. amount of time taken for all instances to finish playing
local function PlaySchemes(instanceOrArray)
    if typeof(instanceOrArray) == "Instance" then
        PlaySchemesOnInstance(instanceOrArray)

        return instanceOrArray:GetAttribute("TimeLength") + instanceOrArray:GetAttribute("DelayBeforePlay")
    elseif typeof(instanceOrArray) == "table" then
        local MaxTimeLength = 0

        for _, instance in ipairs(instanceOrArray) do
            local timeLength = instance:GetAttribute("TimeLength")
            if timeLength ~= nil then -- Find instances that were setup with an interpolation scheme
                PlaySchemesOnInstance(instance)

                local delayBeforePlay = instance:GetAttribute("DelayBeforePlay")
                if timeLength + delayBeforePlay > MaxTimeLength then
                    MaxTimeLength = timeLength + delayBeforePlay
                end
            end
        end

        return MaxTimeLength
    end
end

return PlaySchemes