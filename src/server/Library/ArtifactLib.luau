local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactLib = {}


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


ArtifactLib.Blessing2 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "HealBonus", 0.1 * factor)
end


ArtifactLib.Exploration2 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "MaxHealthEx", 200 * factor)
end


return ArtifactLib
