
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local GlobalTimer = require(SSS.HarukaServer.Shared.GlobalTimer)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerLib = require(SSS.HarukaServer.Services.ServerLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local StatusBook = require(RepS.HarukaShared.Library.StatusBook)

local StatusLib = {}

--// Helper functions

function StatusLib:Heal(char: Model, healAmount: number) : number?
    if not ServerLib:IsCharValid(char) then return end

    local plr = Players:GetPlayerFromCharacter(char)
    if plr == nil then return end

    if char:FindFirstChild("AntiHeal") then return end

    local healBonus = char:GetAttribute("HealBonus") or 100
    healAmount = math.ceil(healAmount * healBonus / 100)

    char.Humanoid.Health += healAmount

    ServerLib:PlayWorldSound(SoundService.SFXs.Healing, char.PrimaryPart.Position)

    Events.PlayHealedScreenFX_S.Fire(plr)
    Events.PlayVFXStatusToPlayer_S.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position, 100), {
        StatusId = "Healing",
        Character = char,
    })

    return healAmount
end
function StatusLib:HealPercentage(char: Model, percentage: number) : number?
    if not ServerLib:IsCharValid(char) then return end

    return StatusLib:Heal(char, math.ceil(char.Humanoid.MaxHealth * percentage / 100))
end

function StatusLib:RestoreMana(char: Model, restoreAmount: number) : number?
    if not ServerLib:IsCharValid(char) then return end

    local plr = Players:GetPlayerFromCharacter(char)
    if plr == nil then return end

    local restoreBonus = char:GetAttribute("RestoreBonus") or 100
    restoreAmount = math.ceil(restoreAmount * restoreBonus / 100)

    HarukaLib:AddAttr(char, "Mana", restoreAmount)

    Events.PlayVFXStatusToPlayer_S.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position, 100), {
        StatusId = "Restoring",
        Character = char,
    })

    return restoreAmount
end
function StatusLib:RestoreManaPercentage(char: Model, percentage: number) : number?
    if not ServerLib:IsCharValid(char) then return end

    local maxMana = char:GetAttribute("MaxMana") or 0
    return StatusLib:RestoreMana(char, math.ceil(maxMana * percentage / 100))
end

function StatusLib:ChargeClassUlt(char: Model, amount: number)
    amount = math.ceil(amount * char:GetAttribute("ClassUltCharge") / 100)

    HarukaLib:AddAttr(char, "ClassUltProgress", amount)
end

function StatusLib:Boost(eff: string, char: Model, props: {
    Power: number?,
    Ex: number?,
    Duration: number,

    TrueEffectId: string?
})
    local effId = eff

    if props.TrueEffectId then
        effId = props.TrueEffectId
    end
    if not ServerLib:IsCharValid(char) then return end

    local power = props.Power or 0
    local ex = props.Ex or 0
    local exAttr = effId.."Ex"
    local powerAttr = effId.."ExPower"

    if power == 0 and ex == 0 then return end

    if not char:GetAttribute(exAttr) then
        warn("Invalid boost effect: "..effId)
        return
    end
    if not char:GetAttribute(powerAttr) then
        warn("Invalid boost effect: "..effId)
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
    effectSymbol.Name = eff
    effectSymbol.Value = eff.."Boost"

    effectSymbol:SetAttribute("Ex", ex)
    effectSymbol:SetAttribute("ExPower", power)
    effectSymbol:SetAttribute("EndClock", DateTime.now().UnixTimestamp + props.Duration)

    effectSymbol:SetAttribute("TaskUniqueId", taskUniqueId)

    effectSymbol.Parent = char.EffectList
    Debris:AddItem(effectSymbol, props.Duration)
end

function StatusLib:ATKBoost(char: Model, props: {
    DMGPower: number?,
    DMG: number?,

    Duration: number,
})
    if not ServerLib:IsCharValid(char) then return end

    local plr = Players:GetPlayerFromCharacter(char)
    if plr == nil then return end

    local power = props.DMGPower or 0
    local ex = props.DMG or 0

    Events.PlayStatPoweredScreenFX_S.Fire(plr)

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
    effectSymbol.Name = "ATK"
    effectSymbol.Value = "ATKBoost"

    effectSymbol:SetAttribute("Ex", ex)
    effectSymbol:SetAttribute("ExPower", power)
    effectSymbol:SetAttribute("EndClock", DateTime.now().UnixTimestamp + props.Duration)

    effectSymbol:SetAttribute("TaskUniqueId", taskUniqueId)

    effectSymbol.Parent = char.EffectList
    Debris:AddItem(effectSymbol, props.Duration)
end

function StatusLib:CreateCustomStatus(eff: string, char: Model, props: {
    Duration: number,
    PlayerOnly: string?,
    IsDebuff: boolean?,
})
    if not ServerLib:IsCharValid(char) then return end

    local boostStr = "Boost"
    if props.IsDebuff then
        boostStr = "Debuff"
    end

    local effectSymbol = Instance.new("StringValue")
    effectSymbol.Name = "EffectSymbol"
    effectSymbol.Value = eff..boostStr

    effectSymbol:SetAttribute("Ex", 0)
    effectSymbol:SetAttribute("ExPower", 1)
    effectSymbol:SetAttribute("EndClock", DateTime.now().UnixTimestamp + props.Duration)

    effectSymbol:SetAttribute("TaskUniqueId", HttpService:GenerateGUID(false))

    effectSymbol:SetAttribute("_PlayerOnly", props.PlayerOnly)

    effectSymbol.Parent = char.EffectList
    Debris:AddItem(effectSymbol, props.Duration)
end

local function _calDoTDMG(char: Model, dmgType: "DMG" | "Magic")
    if char:HasTag("PlayerCharEntity") then
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

    elseif char:HasTag("EnemyEntity") then
        return char:GetAttribute("DMG")
    end
end
local function _doDoTDMG(target: Model, dmg: number, eff: string)
    local targetHumanoid = target.Humanoid :: Humanoid

    targetHumanoid:TakeDamage(dmg)
    ServerLib:ShowNumber(target, dmg, StatusBook[eff].Color)

    if target:HasTag("PlayerCharEntity") then
        target.PlayerGotHit:Fire(target.Name, dmg, "Health")
    end
end

--// DoT Effects

StatusLib.DoT = {}

StatusLib.DoT.Burn = function(target: Model, info: {
    Type: string,
    Creator: Model,
    Power: number,
    Duration: number,
})
    local dmg = _calDoTDMG(info.Creator, "Magic")

    dmg *= info.Power
    dmg /= 3
    dmg = math.floor(dmg)

    _doDoTDMG(target, dmg, "BurnDebuff")
end

StatusLib.DoT.Bleed = function(target: Model, info: {
    Type: string,
    Creator: Model,
    Power: number,
    Duration: number,
})
    local dmg = _calDoTDMG(info.Creator, "DMG")

    dmg *= info.Power
    dmg /= 2.5
    dmg = math.floor(dmg)

    _doDoTDMG(target, dmg, "BleedDebuff")
end
StatusLib.DoT.BloodButchered = function(target: Model, info: {
    Type: string,
    Creator: Model,
    Power: number,
    Duration: number,
})
    local dmg = _calDoTDMG(info.Creator, "DMG")

    dmg *= info.Power
    dmg *= 0.05
    dmg = math.floor(dmg)

    _doDoTDMG(target, dmg, "BloodButcheredDebuff")
end

StatusLib.DoT.Poison = function(target: Model, info: {
    Type: string,
    Creator: Model,
    Power: number,
    Duration: number,
})
    local dmg = _calDoTDMG(info.Creator, "Magic")

    dmg *= info.Power
    dmg /= 2.5
    dmg = math.floor(dmg)

    _doDoTDMG(target, dmg, "PoisonDebuff")
end

return StatusLib