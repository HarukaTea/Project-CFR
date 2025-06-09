--!nocheck

local RunService = game:GetService("RunService")
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local ComplexVFXLib = {}

--// Helper functions

ComplexVFXLib.Healing = function(part: BasePart)
    local adornee = part.Parent :: Model

    if not adornee:IsA("Model") then return end

    local conn; conn = RunService.RenderStepped:Connect(function()
        if not ClientLib:IsModelValid(adornee) then conn:Disconnect() return end

        part.CFrame = adornee.PrimaryPart.CFrame * CFrame.new(0, -2.7, 0)
    end)
end
ComplexVFXLib.Restoring = ComplexVFXLib.Healing



return ComplexVFXLib
