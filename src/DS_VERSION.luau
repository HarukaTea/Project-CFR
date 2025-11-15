
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)


local isMainPlace = game.GameId == AssetBook.CFUniverseId_Main
if not isMainPlace then
    return {
        Id = "_CFT_TEST_DATA",
        OldId = "_CFT_0625"
    }
else
    return {
        Id = "_CF_RELEASE_DATA",
        OldId = "_PRESSURE_TEST_0506"
    }
end
