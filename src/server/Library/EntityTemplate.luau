
local entityStats = {
    Level = 1,

    IsInCombat = false,
    IsDead = false,

    EnteringCombat = false,
    EnteredCombat = false,

    EffectList = {},
    TargetingList = {},
    TeamUpEnemies = {},
    PartyMembers = {},
    TargetingPlayer = "_OBJECT",

    CombatLocation = CFrame.identity,

    IsBoss = false,
    TotalTargeting = 1,


    --- stats
    DMG = 10,
    DMGEx = 0,
    DMGExPower = 1,

    Speed = 10,
    SpeedEx = 0,
    SpeedExPower = 1,

    MaxHealth = 100,
    MaxHealthEx = 0,
    MaxHealthExPower = 1,

    EnvironmentBonus = 1,
}

local cloned = table.clone(entityStats)

-- for some reason, the original table can not access Ex and ExPower sometimes
-- so we need to manually clone one
for attr: string, val: any in entityStats do
    if cloned[attr.."Ex"] and cloned[attr.."ExPower"] then
        cloned["Base"..attr] = val
    end
end


return table.clone(cloned)
