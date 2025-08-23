
local charStats = {
    --- misc
    IsInCombat = false,
    AreaIn = "None",

    --- default stats
    MinDMG = 8,
    MaxDMG = 15,
    Magic = 10,

    MaxHealth = 100,
    HealthRegenWaitTime = 15,

    Shield = 0,
    MaxShield = 1,
    ShieldRegenWaitTime = 10,

    BaseSpeed = 40,
    BaseSpeedCombat = 30,
    BaseJumpPower = 50,

    CriChance = 1, --- percentage
    CriDMG = 100, --- percentage
    DodgeChance = 1, --- percentage


    ClassUltProgress = 0,
    MaxClassUltProgress = 100,
    ClassUltCharge = 100, --- percentage


    BurnChance = 0, --- percentage
    PoisonChance = 0, --- percentage
    BleedChance = 0, --- percentage
    FreezeChance = 0, --- percentage
    ShockingChance = 0, --- percentage
    SlowChance = 0, --- percentage


    --- combat related
    OrbSpawnTimesAtStart = 1,
    OrbSpawnTime = 3,
    OrbFadeTime = 12,
    OrbBounce = 100, --- percentage

    Intensity = 0, --- percentage
    Warding = 0, --- percentage
    Drawback = 0, --- percentage
    Luck = 0, --- percentage


    EffectList = {},
    TargetingList = {},
    TargetingEnemy = "_OBJECT",

    --- class related
    ChainCombo = 0,
    BurstArrow = 0,
    FlowHeat = 0,


    --- item related
    CanMine = false,
    CanYellowLight = false,
    CanBlueLight = false,
    CanClimb = false,



    --- misc
    IsHPRecovering = false,
    IsShieldRepairing = false,

    --- events
    PlayerGotHit = "_EVENT",
    PlayerCombatEnded = "_EVENT",
    PlayerDied = "_EVENT",
    PlayerTargetAdded = "_EVENT",


    --- perk related
    ClassAttackBonusDMG = 100, -- percentage,
    DMGResistBonus = 0, -- percentage,
    SpellCostReduction = 0, -- percentage,
    DMGResistByVIT = 0, -- percentage,
}

local exAndExPowerList = {
    "MinDMG", "MaxDMG", "Magic",
    "MaxHealth", "HealthRegenWaitTime", "MaxShield", "ShieldRegenWaitTime",
    "Speed", "Jump",
    "CriChance", "CriDMG", "DodgeChance", "MaxClassUltProgress", "ClassUltCharge",
    "BurnChance", "PoisonChance", "BleedChance", "FreezeChance", "ShockingChance", "SlowChance",
    "OrbSpawnTimesAtStart", "OrbSpawnTime", "OrbFadeTime", "OrbBounce", "Intensity", "Warding", "Drawback", "Luck",

    "ClassAttackBonusDMG", "DMGResistBonus", "SpellCostReduction"
}
for _, attr: string in exAndExPowerList do
    charStats[attr.."Ex"] = 0
    charStats[attr.."ExPower"] = 1
end



local cloned = table.clone(charStats)

--[[
    for some reasons, the original table can not access Ex and ExPower sometimes
    so we need to manually clone one
]]
for attr: string, val: any in charStats do
    if cloned[attr.."Ex"] and cloned[attr.."ExPower"] then
        cloned["Base"..attr] = val
    end
end

return table.clone(cloned)
