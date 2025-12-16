local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


local effectsFolder = RepS.Packages.Effects :: Folder

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Types = require(script.Parent.Parent.Types)


return function (self: Types.VFXSceneLib)
    local VFXSceneLib = self


    local function initFollower(part: BasePart, char: Model, func: (part: BasePart, char: Model) -> nil)
        local promise; promise = Promise.new(function(resolve, reject)
            while RunService.RenderStepped:Wait() and part do
                if not ClientLib:IsModelValid(char) then promise:cancel() return end

                func(part, char)
            end
        end):catch(function() end)
    end

    VFXSceneLib.Healing = function(char: Model)
        local healEff = effectsFolder.PlayerCommon.Healing:Clone() :: BasePart
        healEff.Parent = char

        Debris:AddItem(healEff, 1.5)
    end

    VFXSceneLib.SpeedBoost = function(char: Model)
        local eff = effectsFolder.Status.Speeding:FindFirstChildOfClass("ParticleEmitter"):Clone() :: ParticleEmitter
        eff.Parent = char.PrimaryPart

        Debris:AddItem(eff, 6)

        Promise.delay(5):andThen(function()
            eff.Enabled = false
        end):catch(function() end)
    end

    VFXSceneLib.Repairing = function(char: Model)
        local repairingEff = effectsFolder.PlayerCommon.Repairing:Clone() :: BasePart
        repairingEff.Parent = char

        Debris:AddItem(repairingEff, 1.5)
    end

    VFXSceneLib.LevelUp = function(char: Model)
        local levelUpEffect = effectsFolder.PlayerCommon.LevelUpEffect:Clone() :: BasePart
        levelUpEffect.Transparency = 1
        levelUpEffect.Parent = char
        Debris:AddItem(levelUpEffect, 2)

        initFollower(levelUpEffect, char, function(part, char)
            part.CFrame = char.PrimaryPart.CFrame
        end)

        HarukaLib:EmitParticles(levelUpEffect)
    end


    VFXSceneLib.SwordSlash = function(char: Model)
        local eff = effectsFolder.PlayerCommon.SwordSlashDissolve:Clone() :: BasePart
        eff.Transparency = 1
        eff.Parent = char.PrimaryPart

        initFollower(eff, char, function(part, char)
            local targeting = char.TargetingEnemy.Value :: Model

            part.CFrame = HarukaLib:CFLookAt(char.PrimaryPart.Position, targeting.PrimaryPart.Position)
            part.CFrame *= CFrame.Angles(0, math.rad(180), 0)
        end)
        HarukaLib:EmitParticles(eff)

        Debris:AddItem(eff, 2)
    end


    VFXSceneLib.SwordPierce = function(char: Model)
        local slash = effectsFolder.PlayerCommon.SwordPierce:Clone() :: BasePart
        slash.Transparency = 1
        slash.Part.Transparency = 1

        local targeting = char.TargetingEnemy.Value :: Model
        local cf = HarukaLib:CFLookAt(char.PrimaryPart.Position, targeting.PrimaryPart.Position) * CFrame.new(0, 0, -2.6)

        slash.CFrame = cf
        slash.CFrame *= CFrame.Angles(0, math.rad(180), 0)
        slash.Parent = workspace.Terrain

        HarukaLib:EmitParticles(slash)

        Debris:AddItem(slash, 1.5)
    end


    VFXSceneLib.UltHighlight = function(char: Model)
        local eff = effectsFolder.PlayerCommon.UltHighlight:Clone() :: Highlight
        eff.Adornee = char
        eff.Parent = char

        Debris:AddItem(eff, 3)
    end
end