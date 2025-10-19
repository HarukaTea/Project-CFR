--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)


local isTestPlace = false
for placeId: string, placeNumberId: number in AssetBook.PlaceIds do
    if placeNumberId == game.PlaceId and string.find(placeId, "Test") then
        isTestPlace = true
        break
    end
end
if isTestPlace then return "_CFT_0625" end



return "_PRESSURE_TEST_0506"