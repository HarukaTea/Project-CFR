local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactLib = {}


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


--// STR

ArtifactLib.STR1 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "ClassAttackBonusDMGExPower", 0.05 * factor)
end


return ArtifactLib
