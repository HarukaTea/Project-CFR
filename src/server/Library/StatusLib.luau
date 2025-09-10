--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

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
local StatusBook = require(RepS.HarukaShared.Library.StatusBook)

local StatusLib = {}


--// Helper functions

StatusLib.Heal = function(char: Model, healAmount: number) : number
    if not ServerLib.IsCharValid(char) then return end

    local plr = Players:GetPlayerFromCharacter(char)
    if plr == nil then return end

    if char:FindFirstChild("AntiHeal") then return end

    local healBonus = char:GetAttribute("HealBonus") or 100
    healAmount = math.ceil(healAmount * healBonus / 100)

    char.Humanoid.Health += healAmount

    local healEff = RepS.Packages.Effects.Healing:Clone() :: BasePart
	healEff.Parent = char
	Debris:AddItem(healEff, 1.5)

    ServerLib.PlayWorldSound(SoundService.SFXs.Healing, char.PrimaryPart.Position)

    Events.PlayHealScreenFX.Fire(plr)

    return healAmount
end
StatusLib.HealPercentage = function(char: Model, percentage: number) : number
    if not ServerLib.IsCharValid(char) then return end

    return StatusLib.Heal(char, math.ceil(char.Humanoid.MaxHealth * percentage / 100))
end




StatusLib.CreateCustomEffect = function(eff: string, char: Model, props: {
    Duration: number,
})
    if not ServerLib.IsCharValid(char) then return end

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



StatusLib.NormalBoostForEntity = function(eff: string, char: Model, props: {
    Power: number?,
    Ex: number?,

    Duration: number,
})
    if not ServerLib.IsCharValid(char) then return end

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
        if not ServerLib.IsCharValid(char) then return end

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



StatusLib.DMGBoost = function(char: Model, props: {
    DMGPower: number?,
    DMG: number?,

    Duration: number,
})
    if not ServerLib.IsCharValid(char) then return end

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
        if not ServerLib.IsCharValid(char) then return end

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



local function _calDoTDMG(char: Model, dmgType: string)
    if dmgType == "DMG" then
        local minDMG, maxDMG = char:GetAttribute("MinDMG"), char:GetAttribute("MaxDMG")
        if minDMG > maxDMG then
            maxDMG, minDMG = minDMG, maxDMG
        end

        return minDMG
    elseif dmgType == "Magic" then
        local magic = char:GetAttribute("Magic")

        return magic
    end
end


StatusLib.Burn = function(target: Model, info: {
    Type: string,
    Creator: Model,
    Power: number,
    Duration: number,
})
    local dmg = _calDoTDMG(info.Creator, "Magic")

    dmg *= info.Power
    dmg /= 3
    dmg = math.floor(dmg)

    target.Humanoid:TakeDamage(dmg)
    ServerLib.ShowNumber(target, dmg, StatusBook.BurnDebuff.Color)
end


StatusLib.Bleed = function(target: Model, info: {
    Type: string,
    Creator: Model,
    Power: number,
    Duration: number,
})
    local dmg = _calDoTDMG(info.Creator, "DMG")

    dmg *= info.Power
    dmg /= 2.5
    dmg = math.floor(dmg)

    target.Humanoid:TakeDamage(dmg)
    ServerLib.ShowNumber(target, dmg, StatusBook.BleedDebuff.Color)
end
StatusLib.BloodButchered = function(target: Model, info: {
    Type: string,
    Creator: Model,
    Power: number,
    Duration: number,
})
    local dmg = _calDoTDMG(info.Creator, "DMG")

    dmg *= info.Power
    dmg *= 0.05
    dmg = math.floor(dmg)

    target.Humanoid:TakeDamage(dmg)
    ServerLib.ShowNumber(target, dmg, StatusBook.BloodButcheredDebuff.Color)
end


StatusLib.Poison = function(target: Model, info: {
    Type: string,
    Creator: Model,
    Power: number,
    Duration: number,
})
    local dmg = _calDoTDMG(info.Creator, "Magic")

    dmg *= info.Power
    dmg /= 2.5
    dmg = math.floor(dmg)

    target.Humanoid:TakeDamage(dmg)
    ServerLib.ShowNumber(target, dmg, StatusBook.PoisonDebuff.Color)
end



shared.StatusLib = StatusLib


return StatusLib