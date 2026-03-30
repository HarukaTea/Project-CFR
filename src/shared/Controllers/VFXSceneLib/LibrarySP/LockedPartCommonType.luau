
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local ClientLib = require(ReplicatedStorage.HarukaShared.Controllers.ClientLib)
local Types = require(script.Parent.Parent.Types)

return function (self: Types.VFXSceneLib)
    local VFXSceneLib = self

    VFXSceneLib.LockedPartTypes = {}

    VFXSceneLib.LockedPartTypes.Healing = function(part: BasePart)
        local adornee = part.Parent :: Model

        if not adornee:IsA("Model") then return end

        local promise; promise = Promise.new(function(resolve, reject)
            while RunService.RenderStepped:Wait() and part do
                if not ClientLib:IsModelValid(adornee) then promise:cancel() return end

                part.CFrame = adornee.PrimaryPart.CFrame * CFrame.new(0, -2.7, 0)
            end
        end):catch(function() end)
    end
    VFXSceneLib.LockedPartTypes.Restoring = VFXSceneLib.LockedPartTypes.Healing
    VFXSceneLib.LockedPartTypes.Repairing = VFXSceneLib.LockedPartTypes.Healing
end