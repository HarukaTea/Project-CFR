local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PerkLib = {}


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


--// STR

PerkLib.HeavyHit = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "MinDMGExPower", 0.05 * factor)
    HarukaLib:AddAttr(char, "MaxDMGExPower", 0.05 * factor)
end


PerkLib.Endurance = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "MaxHealthExPower", 0.05 * factor)
end


PerkLib.IronWill = function(char: Model, factor: number)
    --// TODO: knockback reduction
end


PerkLib.FirstStrike = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "FullHealthEnemyDMGBonusExPower", 0.1 * factor)
end


PerkLib.WarriorPride = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "MinDMGExPower", 0.1 * factor)
    HarukaLib:AddAttr(char, "MaxDMGExPower", 0.1 * factor)
end


return PerkLib
