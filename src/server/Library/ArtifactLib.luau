--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactLib = {}


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


ArtifactLib.Blessing2 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "HealBonusEx", 10 * factor)
end
ArtifactLib.Blessing3 = function()

end


ArtifactLib.Exploration2 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "MaxHealthEx", 200 * factor)
end
ArtifactLib.Exploration3 = function()

end


ArtifactLib.FireEmblem2 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "BurnChanceEx", 10 * factor)
end
ArtifactLib.FireEmblem3 = function()

end


ArtifactLib.Crimson2 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "MagicExPower", 0.18 * factor)
end
ArtifactLib.Crimson3 = function()

end
ArtifactLib.Crimson3Destroying = function(char: Model)
    local state = char:GetAttribute("_PRIVATE_Crimson3") :: boolean
    state = state or false

    char:SetAttribute("_PRIVATE_Crimson3", false)

    if state then
        HarukaLib:AddAttr(char, "MagicExPower", -0.35)
    end
end


ArtifactLib.WolfKing2 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "CriChanceEx", 12 * factor)
end
ArtifactLib.WolfKing3 = function()

end


ArtifactLib.QueenBee2 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "ClassUltDMGBonusExPower", 0.2 * factor)
end
ArtifactLib.QueenBee3 = function()

end


ArtifactLib.Library2 = function()

end
ArtifactLib.Library3 = function()

end


ArtifactLib.ForestDweller2 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "MinDMGExPower", 0.18 * factor)
    HarukaLib:AddAttr(char, "MaxDMGExPower", 0.18 * factor)
end
ArtifactLib.ForestDweller3 = function(char: Model, factor: number)
    char:SetAttribute("ForestDweller3Bonus", factor > 0)
end


ArtifactLib.Northerner2 = function(char: Model, factor: number)
    HarukaLib:AddAttr(char, "ClassUltChargeExPower", 0.2 * factor)
end
ArtifactLib.Northerner3 = function()

end


return ArtifactLib