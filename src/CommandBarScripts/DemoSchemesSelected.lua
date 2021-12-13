local InterpolationScheme = game:GetService("ReplicatedStorage"):FindFirstChild("InterpolationScheme", true)
local PlaySchemes = require(InterpolationScheme.PlaySchemes)
local GetSchemesFor = require(InterpolationScheme.GetSchemesFor)

local DELAY_BETWEEN_DEMOS = 0.4
local NUM_DEMOS = 3

local function GetInitialState(instance)
    local initialState = {}

    local Schemes, applyTo = GetSchemesFor(instance)

    for _, Scheme in pairs(Schemes) do
        Scheme._InsertResetState(initialState, instance, applyTo)
    end

    return initialState
end

local function ResetToInitialState(initialState)
    for objectToReset, initialObjectState in pairs(initialState) do
        for property, value in pairs(initialObjectState) do
            objectToReset[property] = value
        end
    end
end

local function PlaySchemesAndResetAfter(instances)
    -- Gather initial states before playing any schemes
    local allInitialStates = {}
    for _, instance in ipairs(instances) do
        table.insert(allInitialStates, GetInitialState(instance))
    end

    -- Play a demo of all relevant schemes
    for _ = 1, NUM_DEMOS do
        local PlayLength = PlaySchemes(instances)
        
        task.wait(PlayLength + DELAY_BETWEEN_DEMOS)

        -- Reset back to initial state before schemes were played
        for _, initialState in ipairs(allInitialStates) do
            ResetToInitialState(initialState)
        end

        -- Set all instances as no longer playing so that they can be played again
        for _, instance in ipairs(instances) do
            instance:SetAttribute("IsPlaying", false)
        end
    end
end

local SelectionService = game:GetService("Selection")
local SelectedInstances = SelectionService:Get()

-- Unselect everything
SelectionService:Set({})

-- Get all selected instances and their descendants that have schemes setup
local PlayFor = {}
for _, instance in ipairs(SelectedInstances) do
    if instance:GetAttribute("TimeLength") ~= nil then
        table.insert(PlayFor, instance)
    end
    for _, descendant in ipairs(instance:GetDescendants()) do
        if descendant:GetAttribute("TimeLength") ~= nil then
            table.insert(PlayFor, descendant)
        end
    end
end

-- Play all relevant schemes and re-select instances afterwards
PlaySchemesAndResetAfter(PlayFor)

SelectionService:Set(SelectedInstances)