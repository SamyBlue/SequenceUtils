local PlaySchemes = require(game:GetService("ReplicatedStorage"):FindFirstChild("InterpolationScheme", true).PlaySchemes)

local function PlaySchemesAndResetAfter(instance)
    local timeLength = instance:GetAttribute("TimeLength")
    local initialState = {}

    -- Gather initial states before playing any schemes
    if instance:IsA('BasePart') then
        initialState.Size = instance.Size
        initialState.CFrame = instance.CFrame
        initialState.Transparency = instance.Transparency
        initialState.Color = instance.Color
    end

    -- Play a demo of all relevant schemes
    PlaySchemes(instance)

    task.wait(timeLength + 0.1)

    -- Reset back to initial state before schemes were played
    for property, value in pairs(initialState) do
        instance[property] = value
    end

end

for _, obj in ipairs(game:GetService("Selection"):Get()) do
    if obj:GetAttribute("TimeLength") then
        task.spawn(PlaySchemesAndResetAfter, obj)
    end

    for _, descendant in ipairs(obj:GetDescendants()) do
        if descendant:GetAttribute("TimeLength") then
            task.spawn(PlaySchemesAndResetAfter, descendant)
        end
    end
end

--TODO: Reset state after scheme played 