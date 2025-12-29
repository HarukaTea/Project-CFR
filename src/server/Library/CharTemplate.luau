
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


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

    HealBonus = 100, --- percentage

    Shield = 0,
    MaxShield = 1,
    ShieldRegenWaitTime = 10,

    Mana = 100,
    MaxMana = 100,

    RestoreBonus = 100, --- percentage

    BaseSpeed = 40,
    BaseSpeedCombat = 30,
    BaseJumpPower = 50,

    CriChance = 1, --- percentage
    CriDMG = 100, --- percentage
    DodgeChance = 0, --- percentage


    ClassUltProgress = 0,
    MaxClassUltProgress = 100,
    ClassUltCharge = 100, --- percentage
    ClassUltDMGBonus = 100, --- percentage


    BurnChance = 0, --- percentage
    PoisonChance = 0, --- percentage
    BleedChance = 0, --- percentage
    FreezeChance = 0, --- percentage
    ShockingChance = 0, --- percentage

    RESBreak = 100, --- percentage
    Intensity = 0, --- percentage
    Warding = 0, --- percentage
    Luck = 0, --- percentage


    --- combat related
    OrbSpawnTimesAtStart = 1,
    OrbSpawnTime = 3,
    OrbFadeTime = 12,
    OrbBounce = 100, --- percentage

    EffectList = "_FOLDER",
    TargetingList = "_FOLDER",
    TargetingEnemy = "_OBJECT",

    --- item related
    CanMine = false,
    CanLight = false,
    CanClimb = false,


    -- class related
    ChainCombo = 0,
    BurstArrows = 0,
    BurstArrowPiercing = 0,
    FlowMark = 0,
    FuriosoCombo = 0,


    --- misc
    IsClimbing = false,
    IsSwimming = false,

    --- events
    PlayerGotHit = "_EVENT",
    PlayerCombatEnded = "_EVENT",
    PlayerDied = "_EVENT",
    PlayerTargetAdded = "_EVENT",
}

local exAndExPowerList = {
    "MinDMG", "MaxDMG", "Magic",
    "MaxHealth", "HealthRegenWaitTime", "MaxShield", "MaxMana", "ShieldRegenWaitTime", "HealBonus", "RestoreBonus",
    "Speed", "Jump",
    "CriChance", "CriDMG", "DodgeChance", "MaxClassUltProgress", "ClassUltCharge", "ClassUltDMGBonus",
    "BurnChance", "PoisonChance", "BleedChance", "FreezeChance", "ShockingChance",
    "Intensity", "Warding", "Luck", "RESBreak",
    "OrbSpawnTimesAtStart", "OrbSpawnTime", "OrbFadeTime", "OrbBounce",
}
for _, attr: string in exAndExPowerList do
    charStats[attr.."Ex"] = 0
    charStats[attr.."ExPower"] = 1
end



local cloned = HarukaLib.TableUtils.DeepCopy(charStats)

--[[
    for some reasons, the original table can not access Ex and ExPower sometimes
    so we need to manually clone one
]]
for attr, val in charStats do
    if cloned[attr.."Ex"] and cloned[attr.."ExPower"] then
        cloned["Base"..attr] = val
    end
end

return cloned