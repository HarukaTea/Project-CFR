local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PerkLib = {}


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


--// STR

PerkLib.STR1 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "ClassAttackBonusDMGExPower", 0.05 * factor)
end


PerkLib.STR2 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "MaxHealthExPower", 0.1 * factor)
    HarukaLib:AddAttr(char, "MaxShieldExPower", 0.03 * factor)
end


PerkLib.STR3 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "ClassAttackBonusDMGExPower", 0.08 * factor)
    HarukaLib:AddAttr(char, "CriChanceEx", 1 * factor)
end


PerkLib.STR4 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "CriDMGEx", 10 * factor)
end


PerkLib.STR5 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "MaxShieldExPower", 0.07 * factor)
    HarukaLib:AddAttr(char, "WardingEx", 5 * factor)
end


PerkLib.STR6 = function()

end


--// INT

PerkLib.INT1 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "ClassAttackBonusDMGExPower", 0.05 * factor)
end


PerkLib.INT2 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "MaxManaExPower", 0.1 * factor)
    HarukaLib:AddAttr(char, "SpellCostReductionExPower", 0.03 * factor)
end


PerkLib.INT3 = function(char: Model, factor: number)
    --// TODO: ignoring enemy magic resistance
    HarukaLib:AddAttr(char, "CriChanceEx", 1 * factor)
end


PerkLib.INT4 = function(char: Model, factor: number)
    --// TODO: make true difference between class attacks cridmg and spell cridmg
    HarukaLib:AddAttr(char, "CriDMGEx", 10 * factor)
end


PerkLib.INT5 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "IntensityEx", 10 * factor)
end


PerkLib.INT6 = function()

end


--// VIT

PerkLib.VIT1 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "MaxHealthExPower", 0.1 * factor)
end


PerkLib.VIT2 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "MaxHealthExPower", 0.05 * factor)
end


PerkLib.VIT3 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "MaxShieldExPower", 0.05 * factor)
end


PerkLib.VIT4 = function()

end


PerkLib.VIT5 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "WardingEx", 10 * factor)
end


PerkLib.VIT6 = function()

end


return PerkLib
