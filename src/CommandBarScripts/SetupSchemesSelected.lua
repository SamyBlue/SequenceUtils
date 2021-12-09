local SetupSchemes = require(game:GetService("ReplicatedStorage"):FindFirstChild("InterpolationScheme", true).SetupSchemes)

for _, obj in ipairs(game:GetService("Selection"):Get()) do
    SetupSchemes(obj)
    SetupSchemes(obj:GetDescendants())
end