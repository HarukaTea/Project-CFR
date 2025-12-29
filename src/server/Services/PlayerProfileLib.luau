
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")



local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local Classbook = require(ReplicatedStorage.HarukaShared.Library.ClassBook)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local FormulaBook = require(ReplicatedStorage.HarukaShared.Library.FormulaBook)
local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local ItemBook = require(ReplicatedStorage.HarukaShared.Library.ItemBook)
local QuestBook = require(ReplicatedStorage.HarukaShared.Library.QuestBook)


local HarukaDatastore = require(ServerScriptService.HarukaServer.Shared.HarukaDatastore)
local PlayerTemplate = require(ServerScriptService.HarukaServer.Library.PlayerTemplate)


export type PlayerProfileLibClass = {
    __index: PlayerProfileLibClass,

    new: (player: Player, profile: HarukaDatastore.Profile<PlayerTemplate.JSON>) -> PlayerProfileLibClass,
    Init: (self: PlayerProfileLibClass) -> nil,
    Destroy: (self: PlayerProfileLibClass) -> nil,


    Player: Player,
    Profile: HarukaDatastore.Profile<PlayerTemplate.JSON>,


    _ValidateSaveData: (self: PlayerProfileLibClass, data: { PlayerTemplate.PlayerDataJSON }) -> { PlayerTemplate.PlayerDataJSON },
    _ValidateMainData: (self: PlayerProfileLibClass, data: { PlayerTemplate.PlayerMainDataJSON }) -> { PlayerTemplate.PlayerMainDataJSON },

    CalDonationAndSave: (profile: HarukaDatastore.Profile<PlayerTemplate.JSON>, plr: Player) -> nil,
    UpdateDonationRank: (self: PlayerProfileLibClass) -> nil,

    GetObjByUniqueId: (self: PlayerProfileLibClass, uniqueId: string) -> PlayerProfileLibClass?,
}


local allProfiles = {} :: { [string]: PlayerProfileLibClass }


local PlayerProfileLib = {} :: PlayerProfileLibClass
PlayerProfileLib.__index = PlayerProfileLib


function PlayerProfileLib.new(player: Player, profile: HarukaDatastore.Profile<PlayerTemplate.JSON>)
    local self = setmetatable({}, PlayerProfileLib)

    self.Player = player
    self.Profile = profile

    self.UniqueId = player:GetAttribute("HarukaUniqueId")


    allProfiles[self.UniqueId] = self

    return self
end



function PlayerProfileLib:Init()
    local profile = self.Profile
    local plr = self.Player

    profile:AddUserId(plr.UserId)
end



function PlayerProfileLib:Destroy()
    allProfiles[self.UniqueId] = nil
end




function PlayerProfileLib:GetObjByUniqueId(uniqueId: string)
    return allProfiles[uniqueId]
end



--// profile functions for CA RPG



function PlayerProfileLib:_ValidateSaveData(dataT: PlayerTemplate.PlayerDataJSON)
    local data = HarukaLib.TableUtils.DeepCopy(dataT)


    --// check class
    local class = data.Class
    if class == nil then
        data.Class = "Chain"
    end
    if not Classbook[data.Class] then
        data.Class = "Chain"
    end


    --// check valid items
    for uniqueId, itemInfo: PlayerTemplate.PlayerItemDataJSON in data.ItemsSQL do
        if itemInfo.ItemId == nil then
            data.ItemsSQL[uniqueId] = nil
            continue
        end
        local trueItemInfo = ItemBook:GetItemInfo(itemInfo.ItemId)

        if uniqueId ~= itemInfo.UniqueId then
            data.ItemsSQL[uniqueId] = nil
            continue
        end
        if not trueItemInfo then
            data.ItemsSQL[itemInfo.UniqueId] = nil
            continue
        end
        if itemInfo.Amount <= 0 then
            data.ItemsSQL[itemInfo.UniqueId] = nil
            continue
        end


        --- clear up old data to save data storage space
        if itemInfo.IsV2ItemStat then
            data.ItemsSQL[itemInfo.UniqueId].IsV2ItemStat = nil
        end
        if itemInfo.Level then
            data.ItemsSQL[itemInfo.UniqueId].Level = nil
        end


        --- migration from old code
        if not itemInfo.IsFav then
            data.ItemsSQL[itemInfo.UniqueId].IsFav = false
        end
        if not itemInfo.IsLocked then
            data.ItemsSQL[itemInfo.UniqueId].IsLocked = false
        end


        if not itemInfo.ItemStat then
            data.ItemsSQL[itemInfo.UniqueId].ItemStat = ServerLib:GiveRandomStatForItem(itemInfo.ItemId)
        end
        if table.find(trueItemInfo.TagsDesync, "NoRandom") or table.find(trueItemInfo.TagsDesync, "Chest") or table.find(trueItemInfo.TagsDesync, "Statue") then
            if itemInfo.ItemStat ~= trueItemInfo.StatInfo then
                data.ItemsSQL[itemInfo.UniqueId].ItemStat = trueItemInfo.StatInfo
            end
        else
            --// migration4: itemstat adder
            if (trueItemInfo.Type == "Accessory" or trueItemInfo.Type == "Weapon") then
                local itemStat = itemInfo.ItemStat
                local itemStatTable = ItemBook:ParseItemStat("Stat", string.split(itemStat, ","))
                local itemStatInJSON = trueItemInfo.StatInfo
                local itemStatTableInJSON = ItemBook:ParseItemStat("Stat", string.split(itemStatInJSON, ","))

                local updatedStatTable = {}
                for statId, templateVal in itemStatTableInJSON do
                    if itemStatTable[statId] then
                        updatedStatTable[statId] = itemStatTable[statId]
                    else
                        updatedStatTable[statId] = ServerLib:RollStat(statId, templateVal)
                    end
                end

                data.ItemsSQL[itemInfo.UniqueId].ItemStat = ItemBook:BuildItemStat("Stat", updatedStatTable)
            end
        end
    end


    --// check valid item stacks
    for _, itemInfo: PlayerTemplate.PlayerItemDataJSON in data.ItemsSQL do
        if itemInfo.Amount > 1 then
            local itemType = ItemBook:GetItemInfo(itemInfo.ItemId).Type

            if table.find(AssetBook.StackableItemTypes, itemType) then
                for _ = itemInfo.Amount, 2, -1 do
                    local itemUniqueId = HttpService:GenerateGUID(false)

                    data.ItemsSQL[itemUniqueId] = {
                        ItemId = itemInfo.ItemId,
                        Amount = 1,
                        UniqueId = itemUniqueId,
                        ItemStat = ServerLib:GiveRandomStatForItem(itemInfo.ItemId),
                        IsFav = false,
                        IsLocked = false
                    }
                end

                data.ItemsSQL[itemInfo.UniqueId].Amount = 1
            end
            if itemType == "Active" or itemType == "Passive" or itemType == "Quest" then
                local returnAmount = itemInfo.Amount - 1

                data.Gold += math.floor(ItemBook:GetItemInfo(itemInfo.ItemId).Price * returnAmount)
                data.ItemsSQL[itemInfo.UniqueId].Amount = 1
            end
        end

        if itemInfo.Amount > FormulaBook.MAX_ITEM_LIMIT then
            local itemType = ItemBook:GetItemInfo(itemInfo.ItemId).Type

            if itemType == "Consumable" or itemType == "Material" then
                local returnAmount = itemInfo.Amount - FormulaBook.MAX_ITEM_LIMIT

                data.Gold += math.floor(ItemBook:GetItemInfo(itemInfo.ItemId).Price * returnAmount)
                data.ItemsSQL[itemInfo.UniqueId].Amount = FormulaBook.MAX_ITEM_LIMIT
            end
        end
    end


    --// check "NoDuplicate" or "Chest" or "Statue" tag item
    local noDuplicateUniqueIds = {}
    for _, itemInfo: PlayerTemplate.PlayerItemDataJSON in data.ItemsSQL do
        local trueItemInfo = ItemBook:GetItemInfo(itemInfo.ItemId)

        if table.find(trueItemInfo.TagsDesync, "NoDuplicate") or table.find(trueItemInfo.TagsDesync, "Chest") or table.find(trueItemInfo.TagsDesync, "Statue") then
            if noDuplicateUniqueIds[trueItemInfo.ItemId] == nil then
                noDuplicateUniqueIds[trueItemInfo.ItemId] = {}
            end

            table.insert(noDuplicateUniqueIds[trueItemInfo.ItemId], itemInfo.UniqueId)
        end
    end
    for _, uniqueIds: { string } in noDuplicateUniqueIds do
        if #uniqueIds > 1 then
            for i = 2, #uniqueIds do
                data.ItemsSQL[uniqueIds[i]] = nil
            end
        end
    end


    --// mirgration2: check if there is forVariant stat in each item
    for _, itemInfo: PlayerTemplate.PlayerItemDataJSON in data.ItemsSQL do
        local itemStat = itemInfo.ItemStat

        local cleaned = string.gsub(itemStat, "ForVariant%b()", "")

        cleaned = string.gsub(cleaned, ",+", ",")
        cleaned = string.gsub(cleaned, "^,|,$", "")
        cleaned = string.gsub(cleaned, ",,", ",")

        data.ItemsSQL[itemInfo.UniqueId].ItemStat = cleaned
    end


    --// clean up old settings
    data.Settings = nil


    --// check valid equipping items
    for thatSlot: string, itemInfo: PlayerTemplate.PlayerEquippingItemDataJSON in data.EquippingItemsSQL do
        --// check if there are other same item id in equipping items
        for slot: string, thatItemInfo: PlayerTemplate.PlayerEquippingItemDataJSON in data.EquippingItemsSQL do
            if thatItemInfo.ItemId == itemInfo.ItemId and slot ~= thatSlot then
                data.EquippingItemsSQL[slot] = nil
            end
        end
        for slot: string, thatItemInfo: PlayerTemplate.PlayerEquippingItemDataJSON in data.EquippingItemsSQL do
            if string.match(thatItemInfo.ItemId, "^(%w+)%d*$") == string.match(itemInfo.ItemId, "^(%w+)%d*$") and slot ~= thatSlot then
                data.EquippingItemsSQL[slot] = nil
            end
        end
        for slot: string, thatItemInfo: PlayerTemplate.PlayerEquippingItemDataJSON in data.EquippingItemsSQL do
            if thatItemInfo.UniqueId == itemInfo.UniqueId and slot ~= thatSlot then
                data.EquippingItemsSQL[slot] = nil
            end
        end

        local trueItemInfo = ItemBook:GetItemInfo(itemInfo.ItemId)
        if not trueItemInfo then
            data.EquippingItemsSQL[thatSlot] = nil
            continue
        end


        --// check type
        if string.find(thatSlot, "Weapon") then
            if trueItemInfo.Type ~= "Weapon" then
                data.EquippingItemsSQL[thatSlot] = nil
                continue
            end
        end
        if string.find(thatSlot, "Accessory") then
            if trueItemInfo.Type ~= "Accessory" then
                data.EquippingItemsSQL[thatSlot] = nil
                continue
            end
        end
        if string.find(thatSlot, "Active") then
            local whiteList = { "Active", "Consumable" }
            if not table.find(whiteList, trueItemInfo.Type) then
                data.EquippingItemsSQL[thatSlot] = nil
                continue
            end
        end
        if string.find(thatSlot, "Cosmetic") then
            local whiteList = { "CosmeticArmor", "CosmeticWeapon" }
            if not table.find(whiteList, trueItemInfo.Type) then
                data.EquippingItemsSQL[thatSlot] = nil
                continue
            end
        end



        --// check if item exists and level is enough
        local itemObj = data.ItemsSQL[itemInfo.UniqueId]
        if itemObj == nil then
            data.EquippingItemsSQL[thatSlot] = nil
            continue
        end
        local trueItemObjItemInfo = ItemBook:GetItemInfo(itemObj.ItemId)
        if trueItemObjItemInfo == nil then
            data.EquippingItemsSQL[thatSlot] = nil
            continue
        end

        local whiteList = { "Accessory", "Active", "Consumable", "Weapon", "CosmeticWeapon", "CosmeticArmor" }
        if not table.find(whiteList, ItemBook:GetItemInfo(itemObj.ItemId).Type) then
            data.EquippingItemsSQL[thatSlot] = nil
            continue
        end
        if data.Level < trueItemObjItemInfo.Level then
            data.EquippingItemsSQL[thatSlot] = nil
            continue
        end
    end



    --// check valid weapon equipping
    local itemUniqueIdForEmptyWeapon = HttpService:GenerateGUID(false)
    local woodenWeapon = nil
    for _, itemObj in data.ItemsSQL do
        if itemObj.ItemId == "WoodenSword" then
            woodenWeapon = itemObj
            break
        end
    end
    if not woodenWeapon then
        data.ItemsSQL[itemUniqueIdForEmptyWeapon] = {
            ItemId = "WoodenSword",
            Amount = 1,
            UniqueId = itemUniqueIdForEmptyWeapon,
            ItemStat = ServerLib:GiveRandomStatForItem("WoodenSword"),
            IsFav = false,
            IsLocked = false
        }
    end
    if not data.EquippingItemsSQL["Weapon1"] then
        data.EquippingItemsSQL["Weapon1"] = {
            ItemId = "WoodenSword",
            UniqueId = itemUniqueIdForEmptyWeapon
        }
    end



    --// check valid quests
    local isAbyss = workspace:GetAttribute("IsAbyss")
    local isDungeon = workspace:GetAttribute("IsDungeon")
    if not isAbyss and not isDungeon then
        for questId: string, _ in data.QuestsV3 do
            if not QuestBook[questId] then
                data.QuestsV3[questId] = nil
            end
        end
        if HarukaLib.TableUtils.IsEmpty(data.QuestsV3) then
            data.QuestsV3.Main1 = {
                Completed = false,
                Objectives = {}
            }
        end
    end


    --// check invalid points

    local totalPoints = data.PerkPoints :: number
    local level = data.Level :: number
    local shouldPoint = FormulaBook.PLAYER_POINT_PER_LEVEL * level

    totalPoints += data.VITPoints
    totalPoints += data.INTPoints
    totalPoints += data.STRPoints
    totalPoints += data.DEXPoints

    if totalPoints ~= shouldPoint then
        data.PerkPoints = shouldPoint
        data.VITPoints = 0
        data.INTPoints = 0
        data.STRPoints = 0
        data.DEXPoints = 0
    end

    local shouldReset = false
    if data.VITPoints < 0 then shouldReset = true end
    if data.INTPoints < 0 then shouldReset = true end
    if data.STRPoints < 0 then shouldReset = true end
    if data.DEXPoints < 0 then shouldReset = true end
    if data.DEXPoints > FormulaBook.PLAYER_MAX_DEX_POINTS then shouldReset = true end

    if shouldReset then
        data.PerkPoints = shouldPoint
        data.VITPoints = 0
        data.INTPoints = 0
        data.STRPoints = 0
        data.DEXPoints = 0
    end


    --// check level
    data.EXP = math.clamp(data.EXP, 0, 1599 * 40 * 15)
    data.EXP = math.floor(data.EXP)

    return data
end



function PlayerProfileLib:_ValidateMainData(dataT: PlayerTemplate.PlayerMainDataJSON)
    local data = HarukaLib.TableUtils.DeepCopy(dataT)

    --// check gamepass purchase logs
    for gamepassId: string, _ in data.GamepassPurchaseLogs do
        if tonumber(gamepassId) then
            --// was saved incorrectly
            local gamepassName = nil
            for gpName: string, gpId: number in AssetBook.GamepassIds do
                if gpId == tonumber(gamepassId) then
                    gamepassName = gpName
                    break
                end
            end
            if not gamepassName then continue end

            data.GamepassPurchaseLogs[gamepassName] = data.GamepassPurchaseLogs[gamepassId]
            data.GamepassPurchaseLogs[gamepassId] = nil
        end
    end

    return data
end


function PlayerProfileLib._GetCurrentDonation(profile: HarukaDatastore.Profile<PlayerTemplate.JSON>) : number
    local totalRobuxGained = 0
    for _, purchaseInfo in profile.Data.GamepassPurchaseLogs do
        if purchaseInfo.Purchased then
            totalRobuxGained += purchaseInfo.PurchasedPrice or 0
        end
    end
    for _, purchaseInfo in profile.Data.DevProductsPurchaseLogs do
        if purchaseInfo.Purchased then
            totalRobuxGained += purchaseInfo.PurchasedPrice or 0
        end
    end

    return totalRobuxGained
end
function PlayerProfileLib.CalDonationAndSave(profile: HarukaDatastore.Profile<PlayerTemplate.JSON>, plr: Player) : number
    local totalRobuxGained = PlayerProfileLib._GetCurrentDonation(profile)
    if totalRobuxGained <= 0 then return 0 end

    ServerBindables.RToUpdateLeaderboardRank:Fire("Player_"..tostring(plr.UserId), totalRobuxGained, "Donation")

    return 1599
end



function PlayerProfileLib:UpdateDonationRank()
    local profile = self.Profile
    if profile == nil then return end


    local totalRobuxGained = PlayerProfileLib._GetCurrentDonation(profile)
    if totalRobuxGained <= 0 then return end

    ServerBindables.RToAwardLeaderboardRank:Fire(self.Player, "Donation")
end




return PlayerProfileLib