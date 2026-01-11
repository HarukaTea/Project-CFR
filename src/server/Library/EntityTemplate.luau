
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local entityStats = {
    Level = 1,

    IsInCombat = false,
    IsDead = false,

    EnteringCombat = false,
    EnteredCombat = false,

    EffectList = "_FOLDER",
    TargetingList = "_FOLDER",
    TeamUpEnemies = "_FOLDER",
    PartyMembers = "_FOLDER",
    TargetingPlayer = "_OBJECT",

    CombatLocation = CFrame.identity,

    IsBoss = false,
    TotalTargeting = 1,

    --- stats
    DMG = 10,
    DMGEx = 0,
    DMGExPower = 1,

    DMGTakenBonus = 100, --- percentage
    DMGTakenBonusEx = 0,
    DMGTakenBonusExPower = 1,

    BreakProgress = 0,
    TotalBreakProgress = 200,
    TotalBreakProgressEx = 0,
    TotalBreakProgressExPower = 1,

    IsInRESBreakStage = false,

    MaxHealth = 100,
    MaxHealthEx = 0,
    MaxHealthExPower = 1,

    EnvironmentBonus = 1,
}

local cloned = HarukaLib.TableUtils.DeepCopy(entityStats)

-- for some reason, the original table can not access Ex and ExPower sometimes
-- so we need to manually clone one
for attr, val in entityStats do
    if cloned[attr.."Ex"] and cloned[attr.."ExPower"] then
        cloned["Base"..attr] = val
    end
end

return cloned