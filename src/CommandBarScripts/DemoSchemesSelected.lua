local PlaySchemes = require(game:GetService("ReplicatedStorage"):FindFirstChild("InterpolationScheme", true).PlaySchemes)

local DELAY_BETWEEN_DEMOS = 0.4
local NUM_DEMOS = 3

local SelectionService = game:GetService("Selection")
local SelectedInstances = SelectionService:Get()
game.Selection:Set({})

local function GetInitialState()

end

local function ResetToInitialState()

end

local function PlaySchemesAndResetAfter(instance)
    local TimeLength = instance:GetAttribute("TimeLength")
    local IsPlaying = instance:GetAttribute("IsPlaying")

    if IsPlaying == true then
        return
    end
    
    local initialState = {}

    -- Gather initial states before playing any schemes
    if instance:IsA('BasePart') then
        initialState.Size = instance.Size
        initialState.CFrame = instance.CFrame
        initialState.Transparency = instance.Transparency
        initialState.Color = instance.Color
    end

    -- Play a demo of all relevant schemes
    for _ = 1, NUM_DEMOS do
        PlaySchemes(instance)
        
        task.wait(TimeLength + DELAY_BETWEEN_DEMOS)

        -- Reset back to initial state before schemes were played
        for property, value in pairs(initialState) do
            instance[property] = value
        end

        instance:SetAttribute("IsPlaying", false)
    end

    game.Selection:Set(SelectedInstances)
end

for _, obj in ipairs(SelectedInstances) do
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