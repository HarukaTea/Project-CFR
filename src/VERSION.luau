
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)

local TESTING_VERSION = "CF_PT3_TESTING"

if game.PlaceId == AssetBook.PlaceIds.AbyssLevelTest then return TESTING_VERSION end
if game.PlaceId == AssetBook.PlaceIds.MainworldTest then return TESTING_VERSION end





return "CF_PT3_REL_0626"