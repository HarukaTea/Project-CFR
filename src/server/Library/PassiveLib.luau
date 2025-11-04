

local ReplicatedStorage = game:GetService("ReplicatedStorage")



local PassiveLib = {}


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)



PassiveLib.BloodSpellbook = function(char: Model)
    char:SetAttribute("BloodSpellbookBonus", nil)
end



return PassiveLib
