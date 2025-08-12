local BadgeService = game:GetService("BadgeService")
local CollectionService = game:GetService("CollectionService")
local AnalyticsService = game:GetService("AnalyticsService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local PlayerLib = {}
PlayerLib.__index = PlayerLib


local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local Classbook = require(ReplicatedStorage.HarukaShared.Library.ClassBook)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local FormulaBook = require(ReplicatedStorage.HarukaShared.Library.FormulaBook)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)
local ProfileStore = require(ServerScriptService.HarukaServer.Shared.ProfileStore)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local ItemBook = require(ReplicatedStorage.HarukaShared.Library.ItemBook)
local QuestBook = require(ReplicatedStorage.HarukaShared.Library.QuestBook)
local QuestLib = require(ServerScriptService.HarukaServer.Services.QuestLib)

local RankBook = require(ReplicatedStorage.HarukaShared.Library.RankBook)

local PlayerTemplate = require(ServerScriptService.HarukaServer.Library.PlayerTemplate)
local EXTRA_TEMPLATE = require(ServerScriptService.HarukaServer.Library.PlayerExtraAttrs)


local profileStoreMain = ProfileStore.New(
    require(ServerScriptService.DS_VERSION),
    PlayerTemplate
)

local totalPlayersJoined = 0
local allPlayerObjPool = {}


local wait = task.wait


local attrWhiteList = {}
for attr: string, val: any in table.clone(PlayerTemplate).Slot1.Attrs do
    if typeof(val) == "table" then
        continue
    end
    table.insert(attrWhiteList, attr)
end


--// Init once
Players.PlayerRemoving:Connect(function(player)
    player:SetAttribute("IsLeaving", true)

    local playerObj = allPlayerObjPool[player:GetAttribute("HarukaUniqueId")]
    if playerObj then
        playerObj:Destroy()
    end
end)
Events.RequestToChooseWhichSlotToPlay.SetCallback(function(plr: Player, netData)
    local playerObj = allPlayerObjPool[plr:GetAttribute("HarukaUniqueId")]
    if not playerObj then
        plr:Kick("Failed to find player object, please report this to the developer!")
        return
    end

    local self = playerObj


    --// Load in datastore
    Promise.new(function(resolve, reject)
        local slotChosen = netData.SlotId or "Slot1"
        local profile = self.Profile


        --// start to load in
        local slot = slotChosen
        local data = profile.Data[slot].Attrs :: { any }

        self.Slot = slot
        plr:SetAttribute("SlotChosen", slot)

        --// update join time
        data.LastJoinedDateTime = DateTime.now():ToIsoDate()

        for attr: string, val: any in table.clone(EXTRA_TEMPLATE) do
            plr:SetAttribute(attr, val)
        end

        local starterClass = netData.ClassChosen
        if starterClass then
            data.StarterClass = starterClass
        end


        --// validate
        local validatedData = self:_ValidateSaveData(data)
        if validatedData == nil then return end

        profile.Data[slot].Attrs = validatedData


        --// load validated data
        for attr: string, val: any in validatedData do
            if not table.find(attrWhiteList, attr) then continue end

            plr:SetAttribute(attr, val)
        end


        local itemFolder, equippingFolder, questFolder, settingsFolder =
            Instance.new("Folder"), Instance.new("Folder"), Instance.new("Folder"), Instance.new("Configuration")

        itemFolder.Name = "Items"
        equippingFolder.Name = "EquippingItems"
        questFolder.Name = "Quests"
        settingsFolder.Name = "CriRPGSettings"

        itemFolder.Parent = plr
        equippingFolder.Parent = plr
        questFolder.Parent = plr
        settingsFolder.Parent = plr


        for _, itemInfo: { any } in validatedData.ItemsSQL do
            local itemVal = Instance.new("IntConstrainedValue")
            itemVal.MinValue = 0

            local itemType = ItemBook:GetItemInfo(itemInfo.ItemId).Type
            local maxVal = 999
            if itemType == "Active" or itemType == "Passive" then
                maxVal = 1
            end
            if itemType == "Weapon" or itemType == "Accessory" then
                maxVal = 1
            end

            itemVal.MaxValue = maxVal
            itemVal.Value = itemInfo.Amount

            itemVal.Name = itemInfo.ItemId

            itemVal:SetAttribute("HarukaUniqueId", itemInfo.UniqueId)
            itemVal:SetAttribute("Level", itemInfo.Level)
            itemVal:SetAttribute("ItemStat", itemInfo.ItemStat)
            itemVal:SetAttribute("IsFav", itemInfo.IsFav or false)

            itemVal.Parent = itemFolder
        end
        for thatSlot: string, itemInfo: { any } in validatedData.EquippingItemsSQL do
            local itemVal = Instance.new("StringValue")
            itemVal.Name = thatSlot
            itemVal.Value = itemInfo.ItemId

            itemVal:SetAttribute("HarukaUniqueId", itemInfo.UniqueId)

            itemVal.Parent = equippingFolder
        end
        for questId: string, questInfo: { any } in validatedData.QuestsV2 do
            QuestLib.GiveQuest(plr, questId, questInfo.ObjectiveProgress, questInfo.QuestState)
        end
        for settingsId: string, settingsVal: any in validatedData.Settings do
            local val = nil

            if type(settingsVal) == "number" then
                val = Instance.new("NumberValue")
            elseif type(settingsVal) == "boolean" then
                val = Instance.new("BoolValue")
            elseif type(settingsVal) == "string" then
                val = Instance.new("StringValue")
            end
            if val then
                val.Name = settingsId
                val.Value = settingsVal
                val.Parent = settingsFolder
            end
        end


        --// apply player rank in another thread
        Promise.try(function()
            local playerUID = tostring(plr.UserId)

            local hasCustomRole = false
            if RankBook.CustomRoleInfo[playerUID] then
                hasCustomRole = true

                plr:SetAttribute("Role", RankBook.CustomRoleInfo[playerUID].Role)
            end

            local rank = plr:GetRankInGroup(16912246)
            plr:SetAttribute("Rank", rank)


            if not hasCustomRole then
                if RankBook.RankRoleInfo[rank] then
                    plr:SetAttribute("Role", RankBook.RankRoleInfo[rank].Role)
                end
            end
        end):catch(function()  end)


        --// Load in player roles
        local roleContainer = Instance.new("Folder")
        roleContainer.Name = "Roles"
        roleContainer.Parent = plr

        Promise.try(function()
            local isPremium = (plr.MembershipType == Enum.MembershipType.Premium)

            local rank = plr:GetRankInGroup(16912246)
            local isDev = (rank >= 124)
            local isTester = (rank >= 2)
            local isCC = (rank >= 3)
            local isTranslator = (rank >= 4)

            local function _createSymbol(role: string)
                local bool = Instance.new("BoolValue")
                bool.Value = true
                bool.Name = role
                bool.Parent = plr.Roles
            end
            if isPremium then
                _createSymbol("Premium")
            end
            if isDev then
                _createSymbol("Developer")
            end
            if isTranslator and not isDev then
                _createSymbol("Translator")
            end
            if isCC and not isDev and not isTranslator then
                _createSymbol("ContentCreator")
            end
            if isTester and not isDev and not isCC and not isTranslator then
                _createSymbol("Tester")
            end

            if plr.UserId == 304008764 then
                _createSymbol("Translator")
            end
        end):catch(function() end)


        --// load in player badges
        Promise.try(function()
            --// FIXME: this API has a maximum limit of 10 badges per call, need to split it into multiple calls
            local badgesPlayerOwned = BadgeService:CheckUserBadgesAsync(plr.UserId, HarukaLib.TableUtils.Values(AssetBook.BadgeIds))
            for _, badgeId: number in badgesPlayerOwned do
                plr:SetAttribute("BADGE_"..badgeId, true)
            end

        end):catch(function() end)


        --// load in player gamepass and dev products
        Promise.try(function()
            for gamepass: string, gamepassId: number in AssetBook.GamepassIds do
                Promise.try(function()
                    if profile.Data.GamepassPurchaseLogs[gamepass] then return end

                    local ownedGamepass = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, gamepassId)
                    if not ownedGamepass then return end

                    local gamepassInfo = MarketplaceService:GetProductInfo(gamepassId, Enum.InfoType.GamePass)
                    if not gamepassInfo then return end
                    if not gamepassInfo.IsForSale then return end

                    profile.Data.GamepassPurchaseLogs[gamepass] = {
                        PurchaseDateTime = DateTime.now():ToIsoDate(),
                        Purchased = true,
                        PurchasedPrice = gamepassInfo.PriceInRobux
                    }

                end):catch(function() end)
            end


            PlayerLib.CalDonationAndSave(profile, plr)
        end)


        --// FIXME: PT3 Badge, remove this when ended
        ServerLib.GiveBadge(2853156407323188, plr)



        --// done
        totalPlayersJoined += 1

        plr:SetAttribute("JoinOrder", totalPlayersJoined)
        plr:AddTag("PlayerEntity")
        plr:SetAttribute("_PlayerDataInited", true)

        self.Add(HarukaLib.Clock(45, function()
            self:_SaveData()
        end))
        self.Add(HarukaLib.Clock(15, function()
            HarukaLib:AddAttr(plr, "PlayTime", 15)
        end))

        ServerBindables.RToSpawnChar:Fire(plr)

        self:UpdateDonationRank()
        self.Add(HarukaLib.Clock(77, function()
            self:UpdateDonationRank()
        end))

        if plr:FindFirstChild("ProfileContainer") then
            plr.ProfileContainer:Destroy()
        end

        resolve()

	end):timeout(30):catch(function(err)
        if Promise.Error.isKind(err, Promise.Error.Kind.TimedOut) then
            plr:Kick("Your data failed to load, reason: Timed out, please try again later?")
        else
            plr:Kick("Your data failed to load, reason: Internal, please contact us in community!")
            warn(tostring(err))
        end
    end)
end)
Events.RequestToEraseSaveFile.SetCallback(function(plr: Player, data)
    if data.SlotId == nil then return end


    Events.CreateFSNotify.Fire(plr, "Erasing your save file...", 3)


    local playerObj = allPlayerObjPool[plr:GetAttribute("HarukaUniqueId")]
    if not playerObj then
        warn("[Data Erase] Player object not found when trying to erase save file.")

        Events.CreateNotify.Fire(plr, "[ERROR] Player object not found, when trying to erase save file.")
        return
    end
    if not playerObj.Profile then
        warn("[Data Erase] Profile not found when trying to erase save file.")

        Events.CreateNotify.Fire(plr, "[ERROR] Profile not found, when trying to erase save file.")
        return
    end


    for attr: string, value: any in table.clone(PlayerTemplate).Slot1.Attrs do
        playerObj.Profile.Data[data.SlotId].Attrs[attr] = value
    end

    local profileContainer = plr.ProfileContainer :: Folder
    for attr: string, val: any in table.clone(PlayerTemplate).Slot1.Attrs do
        if not table.find(attrWhiteList, attr) then continue end

        profileContainer:SetAttribute(data.SlotId.."_"..attr, val)
    end
    if profileContainer:FindFirstChild(data.SlotId.."_Weapon1") then
        profileContainer[data.SlotId.."_Weapon1"].Value = "WoodenSword"
    end


    Events.CreateFSNotify.Fire(plr, "Save file erased!", 2)
end)



function PlayerLib.new(player: Player)
    if player:GetAttribute("HarukaUniqueId") then return end

    local self = setmetatable({}, PlayerLib)

    self.Player = player
    self.UniqueId = HttpService:GenerateGUID(false)

    self.Player:SetAttribute("HarukaUniqueId", self.UniqueId)

    self.Add, self.Empty = HarukaLib.Bin()


    allPlayerObjPool[self.UniqueId] = self

    return self
end



function PlayerLib:Init()
    local plr = self.Player :: Player

    local profile = nil
    local profileFailedTimes = 0

    while profile == nil do
        wait(2)
        if not plr then break end
        if not plr.Parent then break end
        if profile ~= nil then break end


        Promise.new(function(resolve, reject)
            profile = profileStoreMain:StartSessionAsync("Player_"..plr.UserId, {
                Cancel = function()
                    return plr.Parent ~= Players
                end
            })

            if profile == nil then
                reject("Failed to fetch profile")
                return
            end

            resolve(true)
        end):timeout(8):catch(function(err)
            if Promise.Error.isKind(err, Promise.Error.Kind.TimedOut) then
                Events.CreateNotify.Fire(plr, "Roblox server is running slower than usual, we're trying to load...")
                warn("Roblox server is handling data requests slowly [Timeout]")
            else
                Events.CreateNotify.Fire(plr, "Roblox server is handling requests slowly, we're trying to load...")
            end
        end):await()

        if profile == nil then
            profileFailedTimes += 1
        end
    end

    wait(1.15)
    if profile == nil then
        plr:Kick("Profile session end, please try again later?")
        return
    end
    if plr == nil then return end
    if plr.Parent == nil then return end

    pcall(function()
        if profileFailedTimes > 0 then
            AnalyticsService:LogCustomEvent(plr, "PlayerProfileFailedTimes", profileFailedTimes)
        end
    end)



    --// Load in datastore
    profile:Reconcile()
    profile:AddUserId(plr.UserId)

    profile.OnSessionEnd:Connect(function()
        plr:Kick("Profile session end, Data was loaded on another roblox server, please try again later?")
    end)
    if plr.Parent ~= Players then
        profile:EndSession()
        return
    end

    self.Add(function()
        profile:EndSession()
    end)
    self.Profile = profile


    local profileContainer = Instance.new("Folder")
    profileContainer.Name = "ProfileContainer"
    profileContainer.Parent = plr


    Promise.new(function(resolve)
        for i = 1, 3 do
            local data = self:_ValidateSaveData(profile.Data["Slot"..i].Attrs)

            for attr: string, val: any in data do
                if not table.find(attrWhiteList, attr) then continue end

                profileContainer:SetAttribute("Slot"..i.."_"..attr, val)
            end

            local weapon1 = data.EquippingItemsSQL.Weapon1 :: { any }
            if weapon1 then
                local weapon1Val = Instance.new("StringValue")
                weapon1Val.Name = "Slot"..i.."_Weapon1"
                weapon1Val.Value = weapon1.ItemId
                weapon1Val.Parent = profileContainer
            end
        end
        resolve(true)

    end):catch(function(err)
        warn(tostring(err))

        plr:Kick("An error occurred while initializing your profile, please contact us in community!")
    end):await()


    plr:SetAttribute("_PlayerProfileInited", true)
end



function PlayerLib.GetPlayerObjByUniqueId(uniqueId: string) : PlayerLib
    return allPlayerObjPool[uniqueId]
end




function PlayerLib:Destroy()
    allPlayerObjPool[self.UniqueId] = nil

    self:_Remove()

    self.Empty()
end



--// Private functions

function PlayerLib:_Remove()
    local success, err = pcall(function()
        self:_SaveData()
    end)
    pcall(function()
        if self.Profile then
            self.Profile:EndSession()
        end
    end)
    if not success then
        warn(err)
    end

    self:_RemoveChestAcquire()
    self:_RemoveFromParty()
end



function PlayerLib:_SaveData()
    if not self.Profile then return end
    if not self.Slot then return end
    if self.Player:GetAttribute("Haruka_DataLocked") then return end

    local profileAttrs = self.Profile.Data[self.Slot].Attrs :: { any }
    local nowAttrs = self.Player:GetAttributes()


    for k: string, val: any in profileAttrs do
        if typeof(val) == "table" then continue end
        if nowAttrs[k] == nil then continue end

        profileAttrs[k] = nowAttrs[k]
    end


    local items = self.Player.Items :: Folder
    local equippingItems = self.Player.EquippingItems :: Folder
    local quests = self.Player.Quests :: Folder
    local criSettings = self.Player.CriRPGSettings :: Configuration

    local itemSQL = {}
    local equippingItemsSQL = {}
    local questsV2 = {}
    local criSettingsSQL = {}

    for _, item: IntConstrainedValue in items:GetChildren() do
        if item:IsA("IntConstrainedValue") then
            local uniqueId = item:GetAttribute("HarukaUniqueId") :: string
            local amount = item.Value
            local level = item:GetAttribute("Level") :: number

            if not uniqueId or not amount or not level then
                continue
            end
            if amount <= 0 then continue end

            itemSQL[uniqueId] = {
                ItemId = item.Name,
                Amount = amount,
                UniqueId = uniqueId,
                Level = level,
                ItemStat = item:GetAttribute("ItemStat"),
                IsV2ItemStat = true,
                IsFav = item:GetAttribute("IsFav")
            }
        end
    end
    for _, item: StringValue in equippingItems:GetChildren() do
        if item:IsA("StringValue") then
            local uniqueId = item:GetAttribute("HarukaUniqueId") :: string
            local itemId = item.Value

            if not uniqueId or not itemId then
                continue
            end

            equippingItemsSQL[item.Name] = {
                ItemId = itemId,
                UniqueId = uniqueId
            }
        end
    end
    for _, quest: StringValue in quests:GetChildren() do
        if quest:IsA("StringValue") then
            local questId = quest.Name
            local progressState = quest.Value

            local objectives = quest:GetAttributes()
            if #objectives ~= #QuestBook[questId].Objectives then
                objectives = {}
            end
            if not questId or not progressState then
                continue
            end

            questsV2[questId] = {
                Id = questId,
                QuestState = progressState,
                ObjectiveProgress = objectives
            }
        end
    end
    for _, symbol: any in criSettings:GetChildren() do
        criSettingsSQL[symbol.Name] = symbol.Value
    end

    profileAttrs.ItemsSQL = itemSQL
    profileAttrs.EquippingItemsSQL = equippingItemsSQL
    profileAttrs.QuestsV2 = questsV2
    profileAttrs.Settings = criSettingsSQL


    PlayerLib.CalDonationAndSave(self.Profile, self.Player)
end


function PlayerLib:_RemoveChestAcquire()
    pcall(function()
        for _, chest: Model in CollectionService:GetTagged("ChestEntity") do
            chest:SetAttribute("Receiver_"..self.Player.Name, nil)
        end
    end)
end
function PlayerLib:_RemoveFromParty()
    pcall(function()
        local party = workspace.MapComponents.PartyHolder:FindFirstChild(self.Player.Name) :: ObjectValue?

        if party then
            ServerBindables.PartyInvite:Fire(self.Player, "PlayerLeave", self.Player.Name)
        end
    end)
end




function PlayerLib:_ValidateSaveData(data: { any })
    data = table.clone(data)


    --// check class
    local class = data.Class
    if class == nil then
        data.Class = "Chain"
    end
    if not Classbook[data.Class] then
        data.Class = "Chain"
    end



    --// check valid items
    for uniqueId: string, itemInfo: { any } in data.ItemsSQL do
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
        if trueItemInfo.ItemId == "Dawnbreak" then
            local whiteList = { 304008764, 503716687, 1030029371 }
            if not table.find(whiteList, self.Player.UserId) then
                data.ItemsSQL[itemInfo.UniqueId] = nil
                continue
            end
        end


        if not itemInfo.ItemStat then
            data.ItemsSQL[itemInfo.UniqueId].ItemStat = ServerLib.GiveRandomStatForItem(itemInfo.ItemId)
            data.ItemsSQL[itemInfo.UniqueId].IsV2ItemStat = true
        end
        if not itemInfo.IsV2ItemStat then
            data.ItemsSQL[itemInfo.UniqueId].ItemStat = ServerLib.GiveRandomStatForItem(itemInfo.ItemId)
            data.ItemsSQL[itemInfo.UniqueId].IsV2ItemStat = true
        end
        if not itemInfo.Level then
            data.ItemsSQL[itemInfo.UniqueId].Level = trueItemInfo.Level
        end
        if not itemInfo.IsFav then
            data.ItemsSQL[itemInfo.UniqueId].IsFav = false
        end
        if itemInfo.Level ~= trueItemInfo.Level then
            data.ItemsSQL[itemInfo.UniqueId].Level = trueItemInfo.Level
        end
        if table.find(trueItemInfo.TagsDesync, "NoRandom") then
            if itemInfo.ItemStat ~= trueItemInfo.StatInfo then
                data.ItemsSQL[itemInfo.UniqueId].ItemStat = trueItemInfo.StatInfo
            end
        end
        if table.find(trueItemInfo.TagsDesync, "NoDuplicate") then
            data.ItemsSQL[itemInfo.UniqueId] = nil
        end
        if table.find(trueItemInfo.TagsDesync, "Chest") then
            if itemInfo.ItemStat ~= trueItemInfo.StatInfo then
                data.ItemsSQL[itemInfo.UniqueId].ItemStat = trueItemInfo.StatInfo
            end
        end
    end


    --// check valid item stacks
    for _, itemInfo: { any } in data.ItemsSQL do
        if itemInfo.Amount > 1 then
            local itemType = ItemBook:GetItemInfo(itemInfo.ItemId).Type

            if table.find(AssetBook.StackableItemTypes, itemType) then
                for _ = itemInfo.Amount, 2, -1 do
                    local itemUniqueId = HttpService:GenerateGUID(false)

                    data.ItemsSQL[itemUniqueId] = {
                        ItemId = itemInfo.ItemId,
                        Amount = 1,
                        UniqueId = itemUniqueId,
                        Level = itemInfo.Level,
                        ItemStat = ServerLib.GiveRandomStatForItem(itemInfo.ItemId),
                        IsFav = false
                    }
                end

                data.ItemsSQL[itemInfo.UniqueId].Amount = 1
            end
            if itemType == "Active" or itemType == "Passive" or itemType == "Recipe" or itemType == "Quest" then
                local returnAmount = itemInfo.Amount - 1

                data.Gold += math.floor(ItemBook:GetItemInfo(itemInfo.ItemId).Price * returnAmount)
                data.ItemsSQL[itemInfo.UniqueId].Amount = 1
            end
        end

        if itemInfo.Amount > 999 then
            local itemType = ItemBook:GetItemInfo(itemInfo.ItemId).Type

            if itemType == "Consumable" or itemType == "Material" then
                local returnAmount = itemInfo.Amount - 999

                data.Gold += math.floor(ItemBook:GetItemInfo(itemInfo.ItemId).Price * returnAmount)
                data.ItemsSQL[itemInfo.UniqueId].Amount = 999
            end
        end
    end


    --// check valid equipping items
    for thatSlot: string, itemInfo: { any } in data.EquippingItemsSQL do
        --// check if there are other same item id in equipping items
        for slot: string, thatItemInfo: { any } in data.EquippingItemsSQL do
            if thatItemInfo.ItemId == itemInfo.ItemId and slot ~= thatSlot then
                data.EquippingItemsSQL[slot] = nil
            end
        end
        for slot: string, thatItemInfo: { any } in data.EquippingItemsSQL do
            if string.match(thatItemInfo.ItemId, "^(%w+)%d*$") == string.match(itemInfo.ItemId, "^(%w+)%d*$") and slot ~= thatSlot then
                data.EquippingItemsSQL[slot] = nil
            end
        end
        for slot: string, thatItemInfo: { any } in data.EquippingItemsSQL do
            if thatItemInfo.UniqueId == itemInfo.UniqueId and slot ~= thatSlot then
                data.EquippingItemsSQL[slot] = nil
            end
        end

        local trueItemInfo = ItemBook:GetItemInfo(itemInfo.ItemId)
        if not trueItemInfo then
            data.EquippingItemsSQL[thatSlot] = nil
            continue
        end
        if trueItemInfo.ItemId == "Dawnbreak" then
            local whiteList = { 304008764, 503716687, 1030029371 }
            if not table.find(whiteList, self.Player.UserId) then
                data.EquippingItemsSQL[thatSlot] = nil
                continue
            end
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



        --// check if item exists and level is enough
        local itemObj = data.ItemsSQL[itemInfo.UniqueId]
        if itemObj == nil then
            data.EquippingItemsSQL[thatSlot] = nil
            continue
        end

        local whiteList = { "Accessory", "Active", "Consumable", "Weapon" }
        if not table.find(whiteList, ItemBook:GetItemInfo(itemObj.ItemId).Type) then
            data.EquippingItemsSQL[thatSlot] = nil
            continue
        end
        if data.Level < itemObj.Level then
            data.EquippingItemsSQL[thatSlot] = nil
            continue
        end
    end



    --// check valid weapon equipping
    local woodenSword = nil
    local woodenBow = nil
    local woodenStaff = nil

    for _, itemObj in data.ItemsSQL do
        if itemObj.ItemId == "WoodenSword" then
            woodenSword = itemObj
        end
        if itemObj.ItemId == "WoodenBow" then
            woodenBow = itemObj
        end
        if itemObj.ItemId == "WoodenStaff" then
            woodenStaff = itemObj
        end
    end

    local function _checkIfHasWeapon(weaponId: string)
        local itemUniqueIdForEmptyWeapon = HttpService:GenerateGUID(false)

        data.ItemsSQL[itemUniqueIdForEmptyWeapon] = {
            ItemId = weaponId,
            Amount = 1,
            UniqueId = itemUniqueIdForEmptyWeapon,
            Level = 1,
            IsV2ItemStat = true,
            ItemStat = ServerLib.GiveRandomStatForItem(weaponId),
            IsFav = false
        }
    end
    if not woodenSword then _checkIfHasWeapon("WoodenSword") end
    if not woodenBow then _checkIfHasWeapon("WoodenBow") end
    if not woodenStaff then _checkIfHasWeapon("WoodenStaff") end



    local function _checkIfHasWeaponEquipped()
        local weaponFound = nil
        for _, itemInfo: { any } in data.ItemsSQL do
            if ItemBook:GetItemInfo(itemInfo.ItemId).Type == "Weapon" then
                weaponFound = {
                    ItemId = itemInfo.ItemId,
                    UniqueId = itemInfo.UniqueId
                }
                break
            end
        end

        data.EquippingItemsSQL["Weapon1"] = {
            ItemId = weaponFound.ItemId,
            UniqueId = weaponFound.UniqueId
        }
    end
    if next(data.EquippingItemsSQL) == nil then
        _checkIfHasWeaponEquipped()
    end
    if not data.EquippingItemsSQL["Weapon1"] then
        _checkIfHasWeaponEquipped()
    end



    --// check valid quests
    for questId: string, _ in data.QuestsV2 do
        if not QuestBook[questId] then
            data.QuestsV2[questId] = nil
        end
    end
    if HarukaLib.TableUtils.IsEmpty(data.QuestsV2) then
        data.QuestsV2.Main1 = {
            Id = "Main1",
            QuestState = "Started",
            ObjectiveProgress = {}
        }
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


    return data
end



function PlayerLib._GetCurrentDonation(profile: ProfileStore.Profile) : number
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
function PlayerLib.CalDonationAndSave(profile: ProfileStore.Profile, plr: Player) : number
    local totalRobuxGained = PlayerLib._GetCurrentDonation(profile)
    if totalRobuxGained <= 0 then return 0 end

    ServerBindables.RToUpdateLeaderboardRank:Fire("Player_"..tostring(plr.UserId), totalRobuxGained, "Donation")
end



function PlayerLib:UpdateDonationRank()
    local profile = self.Profile
    if profile == nil then return end


    local totalRobuxGained = self:_GetCurrentDonation(profile)
    if totalRobuxGained <= 0 then return end

    ServerBindables.RToCheckLeaderboardRank:Fire(self.Player, "Donation")
end



shared.PlayerLib = PlayerLib


return PlayerLib
