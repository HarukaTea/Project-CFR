--!nocheck

local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local GlobalTimer = require(SSS.HarukaServer.Shared.GlobalTimer)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local StatusLib = {}


--// Helper functions

StatusLib.Heal = function(_, char: Model, healAmount: number) : number
    if not ServerLib:IsCharValid(char) then return end

    local plr = Players:GetPlayerFromCharacter(char)
    if plr == nil then return end

    char.Humanoid.Health += healAmount

    local healEff = RepS.Packages.Effects.Healing:Clone() :: BasePart
	healEff.Parent = char
	Debris:AddItem(healEff, 1.5)

    ServerLib:PlayWorldSound(SoundService.SFXs.Healing, char.PrimaryPart.Position)

    Events.PlayHealScreenFX.Fire(plr)

    return healAmount
end
StatusLib.HealPercentage = function(_, char: Model, percentage: number) : number
    if not ServerLib:IsCharValid(char) then return end

    return StatusLib:Heal(char, math.ceil(char.Humanoid.MaxHealth * percentage / 100))
end



StatusLib.RestoreMana = function(_, char: Model, manaAmount: number) : number
    if not ServerLib:IsCharValid(char) then return end

    char:SetAttribute("Mana", math.clamp(char:GetAttribute("Mana") + manaAmount, 0, char:GetAttribute("MaxMana")))

    local restoreEff = RepS.Packages.Effects.Restoring:Clone() :: BasePart
    restoreEff.Parent = char

    Debris:AddItem(restoreEff, 1.5)
end
StatusLib.RestoreManaPercentage = function(_, char: Model, percentage: number) : number
    return StatusLib:RestoreMana(char, math.ceil(char:GetAttribute("MaxMana") * percentage / 100))
end



StatusLib.CreateCustomEffect = function(_, eff: string, char: Model, props: {
    Duration: number,
})
    if not ServerLib:IsCharValid(char) then return end

    local effectSymbol = Instance.new("StringValue")
    effectSymbol.Name = "EffectSymbol"
    effectSymbol.Value = eff.."Boost"

    effectSymbol:SetAttribute("Ex", 0)
    effectSymbol:SetAttribute("ExPower", 1)
    effectSymbol:SetAttribute("EndClock", DateTime.now().UnixTimestamp + props.Duration)

    effectSymbol:SetAttribute("TaskUniqueId", HttpService:GenerateGUID(false))

    effectSymbol.Parent = char.EffectList
    Debris:AddItem(effectSymbol, props.Duration)
end



StatusLib.NormalBoostForEntity = function(_, eff: string, char: Model, props: {
    Power: number?,
    Ex: number?,

    Duration: number,
})
    if not ServerLib:IsCharValid(char) then return end

    local power = props.Power or 0
    local ex = props.Ex or 0
    local exAttr = eff.."Ex"
    local powerAttr = eff.."ExPower"

    if power == 0 and ex == 0 then return end

    if not char:GetAttribute(exAttr) then
        warn("Invalid boost effect: "..eff)
        return
    end
    if not char:GetAttribute(powerAttr) then
        warn("Invalid boost effect: "..eff)
        return
    end

    HarukaLib:AddAttr(char, exAttr, ex)
    HarukaLib:AddAttr(char, powerAttr, power)


    local taskUniqueId = GlobalTimer:AddTask(props.Duration, function()
        if not ServerLib:IsCharValid(char) then return end

        HarukaLib:AddAttr(char, exAttr, -ex)
        HarukaLib:AddAttr(char, powerAttr, -power)
    end)


    local effectSymbol = Instance.new("StringValue")
    effectSymbol.Name = "EffectSymbol"
    effectSymbol.Value = eff.."Boost"

    effectSymbol:SetAttribute("Ex", ex)
    effectSymbol:SetAttribute("ExPower", power)
    effectSymbol:SetAttribute("EndClock", DateTime.now().UnixTimestamp + props.Duration)

    effectSymbol:SetAttribute("TaskUniqueId", taskUniqueId)

    effectSymbol.Parent = char.EffectList
    Debris:AddItem(effectSymbol, props.Duration)
end



StatusLib.DMGBoost = function(_, char: Model, props: {
    DMGPower: number?,
    DMG: number?,

    Duration: number,
})
    if not ServerLib:IsCharValid(char) then return end

    local plr = Players:GetPlayerFromCharacter(char)
    if plr == nil then return end


    local power = props.DMGPower or 0
    local ex = props.DMG or 0

    Events.PlayStatPoweredScreenFX.Fire(plr)


    HarukaLib:AddAttr(char, "MaxDMGEx", ex)
    HarukaLib:AddAttr(char, "MinDMGEx", ex)
    HarukaLib:AddAttr(char, "MaxDMGExPower", power)
    HarukaLib:AddAttr(char, "MinDMGExPower", power)


    local taskUniqueId = GlobalTimer:AddTask(props.Duration, function()
        if not ServerLib:IsCharValid(char) then return end

        HarukaLib:AddAttr(char, "MaxDMGEx", -ex)
        HarukaLib:AddAttr(char, "MinDMGEx", -ex)
        HarukaLib:AddAttr(char, "MaxDMGExPower", -power)
        HarukaLib:AddAttr(char, "MinDMGExPower", -power)
    end)


    local effectSymbol = Instance.new("StringValue")
    effectSymbol.Name = "EffectSymbol"
    effectSymbol.Value = "ATKBoost"

    effectSymbol:SetAttribute("Ex", ex)
    effectSymbol:SetAttribute("ExPower", power)
    effectSymbol:SetAttribute("EndClock", DateTime.now().UnixTimestamp + props.Duration)

    effectSymbol:SetAttribute("TaskUniqueId", taskUniqueId)

    effectSymbol.Parent = char.EffectList
    Debris:AddItem(effectSymbol, props.Duration)
end



StatusLib.Burn = function(_, char: Model, info: {
    Target: Model,
    Type: string,
    Creator: string,
    Power: number,
    Duration: number,
})

end


return StatusLib
