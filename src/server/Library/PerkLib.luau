
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PerkLib = {}


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


PerkLib.Blessing2 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "ClassAttackBonusDMGExPower", 0.05 * factor)
end


return PerkLib
