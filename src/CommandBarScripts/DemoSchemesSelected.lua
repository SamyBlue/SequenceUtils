local InterpolationScheme = game:GetService("ReplicatedStorage"):FindFirstChild("InterpolationScheme", true)
local PlaySchemes = require(InterpolationScheme.PlaySchemes)
local GetSchemesFor = require(InterpolationScheme.GetSchemesFor)

local DELAY_BETWEEN_DEMOS = 0.4
local NUM_DEMOS = 2
local START_INVISIBLE = true
local INVISIBLE_DELAY = 0.4

local function HasProperty(object, prop)
    local success, val = pcall(function()
        return object[prop]
    end)
    
    return success and val ~= object:FindFirstChild(prop)
end

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

local function MakeInstancesInvisible(instances, transparencyStates)
    for _, instance in ipairs(instances) do
        if transparencyStates[instance] then
            continue -- prevents overwriting transparency state
        end
        local transparencyState = {}

        if HasProperty(instance, "Transparency") and typeof(instance.Transparency) == "number" and instance.Transparency ~= 1 then
            transparencyState.Transparency = instance.Transparency
            instance.Transparency = 1
        end

        if HasProperty(instance, "Enabled") and typeof(instance.Enabled) == "boolean" and instance.Enabled ~= false then
            transparencyState.Enabled = instance.Enabled
            instance.Enabled = false
        end

        if instance.ClassName == "ParticleEmitter" then
            instance:Clear()
        end

        transparencyStates[instance] = transparencyState
        MakeInstancesInvisible(instance:GetChildren(), transparencyStates) -- make descendants invisible too
    end

    return transparencyStates
end

local function PlaySchemesAndResetAfter(instances)
    -- Gather initial states before playing any schemes
    local allInitialStates = {}
    for _, instance in ipairs(instances) do
        table.insert(allInitialStates, GetInitialState(instance))
    end

    -- Play a demo of all relevant schemes
    for _ = 1, NUM_DEMOS do
        if START_INVISIBLE then
            local transparencyStates = {}
            MakeInstancesInvisible(instances, transparencyStates)
            task.wait(INVISIBLE_DELAY)
            ResetToInitialState(transparencyStates)
        end

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