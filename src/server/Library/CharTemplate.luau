
local charStats = {
    --- misc
    IsInCombat = false,
    AreaIn = "None",

    --- default stats
    MinDMG = 8,
    MinDMGEx = 0,
    MinDMGExPower = 1,
    MaxDMG = 15,
    MaxDMGEx = 0,
    MaxDMGExPower = 1,
    Magic = 10,
    MagicEx = 0,
    MagicExPower = 1,
    Mana = 80,
    MaxMana = 80,
    MaxManaEx = 0,
    MaxManaExPower = 1,
    ManaRegen = 15, --- percentage
    ManaRegenEx = 0,
    ManaRegenExPower = 1,


    MaxHealth = 100,
    MaxHealthEx = 0,
    MaxHealthExPower = 1,
    HealthRegenWaitTime = 15,
    HealthRegenWaitTimeEx = 0,
    HealthRegenWaitTimeExPower = 1,

    Shield = 0,
    MaxShield = 1,
    MaxShieldEx = 0,
    MaxShieldExPower = 1,
    ShieldRegenWaitTime = 10,
    ShieldRegenWaitTimeEx = 0,
    ShieldRegenWaitTimeExPower = 1,


    BaseSpeed = 40,
    BaseSpeedCombat = 30,
    SpeedEx = 0,
    SpeedExPower = 1,
    BaseJumpPower = 50,
    JumpPowerEx = 0,
    JumpPowerExPower = 1,


    CriChance = 1,
    CriChanceEx = 0,
    CriChanceExPower = 1,
    CriDMG = 100, --- percentage
    CriDMGEx = 0,
    CriDMGExPower = 1,
    DodgeChance = 1,
    DodgeChanceEx = 0,
    DodgeChanceExPower = 1,


    ClassUltProgress = 0,
    MaxClassUltProgress = 100,
    MaxClassUltProgressEx = 0,
    MaxClassUltProgressExPower = 1,
    ClassUltCharge = 100, --- percentage
    ClassUltChargeEx = 0,
    ClassUltChargeExPower = 1,


    BurnChance = 0, --- percentage
    BurnChanceEx = 0,
    BurnChanceExPower = 1,


    --- combat related
    OrbSpawnTimesAtStart = 1,
    OrbSpawnTimesAtStartEx = 0,
    OrbSpawnTimesAtStartExPower = 1,
    OrbSpawnTime = 3,
    OrbSpawnTimeEx = 0,
    OrbSpawnTimeExPower = 1,
    OrbFadeTime = 12,
    OrbFadeTimeEx = 0,
    OrbFadeTimeExPower = 1,
    OrbBounce = 100, --- percentage
    OrbBounceEx = 0,
    OrbBounceExPower = 1,

    Intensity = 100, --- percentage
    IntensityEx = 0,
    IntensityExPower = 1,
    Warding = 100, --- percentage
    WardingEx = 0,
    WardingExPower = 1,
    Drawback = 100, --- percentage
    DrawbackEx = 0,
    DrawbackExPower = 1,
    Luck = 0, --- percentage
    LuckEx = 0,
    LuckExPower = 1,

    FullHealthEnemyDMGBonus = 0, --- percentage
    FullHealthEnemyDMGBonusEx = 0,
    FullHealthEnemyDMGBonusExPower = 1,




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
}

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
