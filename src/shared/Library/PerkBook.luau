local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PerkBook = {}

local PerkRawBook = require(ReplicatedStorage.HarukaShared.Library.PerkRawBook)

PerkBook.STR = {}
PerkBook.INT = {}
PerkBook.VIT = {}


for _, perkInfo in PerkRawBook do
    PerkBook[perkInfo.Type][perkInfo.PerkId] = {
        PerkId = perkInfo.PerkId,
        Name = perkInfo.Name,
        Stat = perkInfo.Stat,
        Desc = perkInfo.Desc,
        Req = tonumber(perkInfo.Req) or 500,
        Type = perkInfo.Type
    }
end


return PerkBook
