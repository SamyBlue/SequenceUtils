local PlaySchemes = require(game:GetService("ReplicatedStorage"):FindFirstChild("InterpolationScheme", true).PlaySchemes)
local GetSchemesFor = require(script.Parent.GetSchemesFor)

local DELAY_BETWEEN_DEMOS = 0.4
local NUM_DEMOS = 3

local SelectionService = game:GetService("Selection")
local SelectedInstances = SelectionService:Get()
game.Selection:Set({})

local function GetInitialState(instance)
    local initialState = {}

    local Schemes, applyTo = GetSchemesFor(instance)

    for _, Scheme in pairs(Schemes) do
        Scheme._InsertResetState(initialState, instance, applyTo)
    end

    return initialState, applyTo
end

local function ResetToInitialState(applyTo, initialState)
    for property, value in pairs(initialState) do
        applyTo[property] = value
    end
end

local function PlaySchemesAndResetAfter(instance)
    local TimeLength = instance:GetAttribute("TimeLength")
    local IsPlaying = instance:GetAttribute("IsPlaying")

    if IsPlaying == true then
        return
    end

    -- Gather initial states before playing any schemes
    local initialState, applyTo = GetInitialState(instance)

    -- Play a demo of all relevant schemes
    for _ = 1, NUM_DEMOS do
        PlaySchemes(instance)
        
        task.wait(TimeLength + DELAY_BETWEEN_DEMOS)

        -- Reset back to initial state before schemes were played
        ResetToInitialState(applyTo, initialState)

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