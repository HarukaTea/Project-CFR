local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")


local PlayerLib = {}
PlayerLib.__index = PlayerLib


local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local FormulaBook = require(ReplicatedStorage.HarukaShared.Library.FormulaBook)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)
local ProfileService = require(ServerScriptService.HarukaServer.Shared.ProfileService)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local ItemLib = require(ReplicatedStorage.HarukaShared.Library.ItemLib)
local QuestBook = require(ReplicatedStorage.HarukaShared.Library.QuestBook)
local HarukaQuest = require(ServerScriptService.HarukaServer.Shared.HarukaQuest)

local RankBook = require(ReplicatedStorage.HarukaShared.Library.RankBook)

local PlayerTemplate = require(ServerScriptService.HarukaServer.Library.PlayerTemplate)
local EXTRA_TEMPLATE = require(ServerScriptService.HarukaServer.Library.PlayerExtraAttrs)
local PlayerLimitsTemplate = require(ServerScriptService.HarukaServer.Library.PlayerLimitsTemplate)


local profileStoreMain = ProfileService.GetProfileStore(
    require(ServerScriptService.DS_VERSION),
    PlayerTemplate
)

local totalPlayersJoined = 0

local allPlayerObjPool = {}


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
        local data = profile.Data[slot].Attrs :: table

        self.Slot = slot

        --// update join time
        data.LastJoinedDateTime = DateTime.now():ToIsoDate()

        for attr: string, val: any in table.clone(EXTRA_TEMPLATE) do
            plr:SetAttribute(attr, val)
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

        local itemFolder, equippingFolder, questFolder =
            Instance.new("Folder"), Instance.new("Folder"), Instance.new("Folder")

        itemFolder.Name = "Items"
        equippingFolder.Name = "EquippingItems"
        questFolder.Name = "Quests"

        itemFolder.Parent = plr
        equippingFolder.Parent = plr
        questFolder.Parent = plr


        for _, itemInfo: table in validatedData.ItemsSQL do
            local itemVal = Instance.new("IntConstrainedValue")
            itemVal.MinValue = 0

            local itemType = ItemLib:GetItemInfo(itemInfo.ItemId).Type
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

            itemVal.Parent = itemFolder
        end
        for thatSlot: string, itemInfo: table in validatedData.EquippingItemsSQL do
            local itemVal = Instance.new("StringValue")
            itemVal.Name = thatSlot
            itemVal.Value = itemInfo.ItemId

            itemVal:SetAttribute("HarukaUniqueId", itemInfo.UniqueId)

            itemVal.Parent = equippingFolder
        end
        for questId: string, questInfo: table in validatedData.QuestsV2 do
            HarukaQuest:GiveQuest(plr, questId, questInfo.ObjectiveProgress, questInfo.QuestState)
        end


        --// apply player rank in another thread
        pcall(function()
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
        end)


        --// Load in player roles
        local roleContainer = Instance.new("Folder")
        roleContainer.Name = "Roles"
        roleContainer.Parent = plr

        pcall(function()
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
        end)


        --// FIXME: Pressure test 3 - give badge
        ServerLib:GiveBadge(4241425362230986, plr)



        --// done
        totalPlayersJoined += 1

        plr:SetAttribute("JoinOrder", totalPlayersJoined)
        plr:AddTag("PlayerEntity")
        plr:SetAttribute("_PlayerDataInited", true)

        self.Add(HarukaLib.Clock(60, function()
            self:_SaveData()
        end))
        self.Add(HarukaLib.Clock(15, function()
            HarukaLib:AddAttr(plr, "PlayTime", 15)
        end))

        ServerBindables.RToSpawnChar:Fire(plr)

        self:_ListenStatLimitTracker()

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


    --// Load in datastore
    Promise.new(function(resolve, reject)
		local profile = profileStoreMain:LoadProfileAsync("Player_"..plr.UserId)

        if not profile then reject("Profile is nil") return end

        profile:Reconcile()
		profile:AddUserId(plr.UserId)

		profile:ListenToRelease(function()
			plr:Kick("Data was loaded on another roblox server, please try again later?")
		end)

        self.Add(function()
            profile:Release()
        end)

		if not plr:IsDescendantOf(Players) then
			profile:Release()
			return
		end

        self.Profile = profile


        local profileContainer = Instance.new("Folder")
        profileContainer.Name = "ProfileContainer"
        profileContainer.Parent = plr

        for i = 1, 3 do
            local data = profile.Data["Slot"..i].Attrs :: table

            for attr: string, val: any in data do
                if not table.find(attrWhiteList, attr) then continue end

                profileContainer:SetAttribute("Slot"..i.."_"..attr, val)
            end
        end

        plr:SetAttribute("_PlayerProfileInited", true)
        resolve()

	end):timeout(30):catch(function(err)
        if Promise.Error.isKind(err, Promise.Error.Kind.TimedOut) then
            plr:Kick("Your data failed to load, reason: Timed out, please try again later?")
        else
            plr:Kick("Your data failed to load, reason: Internal, please contact us in community!")
            warn(tostring(err))
        end
    end)
end


function PlayerLib:Destroy()
    allPlayerObjPool[self.UniqueId] = nil

    self:_Remove()

    self.Empty()
end



--// Private functions


function PlayerLib:_Remove()
    Promise.try(function()
        self:_SaveData()
    end)
    Promise.try(function()
        self:_RemoveChestAcquire()
    end)
end



function PlayerLib:_SaveData()
    if not self.Profile then return end
    if not self.Slot then return end
    if self.Player:GetAttribute("Haruka_DataLocked") then return end

    local profileAttrs = self.Profile.Data[self.Slot].Attrs :: table
    local nowAttrs = self.Player:GetAttributes()


    for k: string, val: any in profileAttrs do
        if typeof(val) == "table" then continue end
        if nowAttrs[k] == nil then continue end

        profileAttrs[k] = nowAttrs[k]
    end


    local items = self.Player.Items :: Folder
    local equippingItems = self.Player.EquippingItems :: Folder
    local quests = self.Player.Quests :: Folder

    local itemSQL = {}
    local equippingItemsSQL = {}
    local questsV2 = {}

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
                IsV2ItemStat = true
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

    profileAttrs.ItemsSQL = itemSQL
    profileAttrs.EquippingItemsSQL = equippingItemsSQL
    profileAttrs.QuestsV2 = questsV2
end


function PlayerLib:_RemoveChestAcquire()
    for _, chest: Model in CollectionService:GetTagged("ChestEntity") do
        chest:SetAttribute("Receiver_"..self.Player.Name, nil)
    end
end



function PlayerLib:_ValidateSaveData(data: table)
    data = table.clone(data)


    --// check valid items
    for uniqueId: string, itemInfo: table in data.ItemsSQL do
        local trueItemInfo = ItemLib:GetItemInfo(itemInfo.ItemId)

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


        if not itemInfo.ItemStat then
            data.ItemsSQL[itemInfo.UniqueId].ItemStat = ServerLib:GiveRandomStatForItem(itemInfo.ItemId)
            data.ItemsSQL[itemInfo.UniqueId].IsV2ItemStat = true
        end
        if not itemInfo.IsV2ItemStat then
            data.ItemsSQL[itemInfo.UniqueId].ItemStat = ServerLib:GiveRandomStatForItem(itemInfo.ItemId)
            data.ItemsSQL[itemInfo.UniqueId].IsV2ItemStat = true
        end
        if not itemInfo.Level then
            data.ItemsSQL[itemInfo.UniqueId].Level = trueItemInfo.Level
        end
        if itemInfo.Level ~= trueItemInfo.Level then
            data.ItemsSQL[itemInfo.UniqueId].Level = trueItemInfo.Level
        end
    end


    --// check valid item stacks
    for _, itemInfo: table in data.ItemsSQL do
        if itemInfo.Amount > 1 then
            local itemType = ItemLib:GetItemInfo(itemInfo.ItemId).Type

            if table.find(AssetBook.StackableItemTypes, itemType) then
                for _ = itemInfo.Amount, 2, -1 do
                    local itemUniqueId = HttpService:GenerateGUID(false)

                    data.ItemsSQL[itemUniqueId] = {
                        ItemId = itemInfo.ItemId,
                        Amount = 1,
                        UniqueId = itemUniqueId,
                        Level = itemInfo.Level,
                        ItemStat = ServerLib:GiveRandomStatForItem(itemInfo.ItemId)
                    }
                end

                data.ItemsSQL[itemInfo.UniqueId].Amount = 1
            end
            if itemType == "Active" or itemType == "Passive" or itemType == "Recipe" or itemType == "Quest" then
                local returnAmount = itemInfo.Amount - 1

                data.Gold += math.floor(ItemLib:GetItemInfo(itemInfo.ItemId).Price * returnAmount)
                data.ItemsSQL[itemInfo.UniqueId].Amount = 1
            end
        end

        if itemInfo.Amount > 999 then
            local itemType = ItemLib:GetItemInfo(itemInfo.ItemId).Type

            if itemType == "Consumable" or itemType == "Material" then
                local returnAmount = itemInfo.Amount - 999

                data.Gold += math.floor(ItemLib:GetItemInfo(itemInfo.ItemId).Price * returnAmount)
                data.ItemsSQL[itemInfo.UniqueId].Amount = 999
            end
        end
    end


    --// check valid equipping items
    for thatSlot: string, itemInfo: table in data.EquippingItemsSQL do
        --// check if there are other same item id in equipping items
        for slot: string, thatItemInfo: table in data.EquippingItemsSQL do
            if thatItemInfo.ItemId == itemInfo.ItemId and slot ~= thatSlot then
                data.EquippingItemsSQL[slot] = nil
            end
        end
        for slot: string, thatItemInfo: table in data.EquippingItemsSQL do
            if thatItemInfo.UniqueId == itemInfo.UniqueId and slot ~= thatSlot then
                data.EquippingItemsSQL[slot] = nil
            end
        end

        local trueItemInfo = ItemLib:GetItemInfo(itemInfo.ItemId)
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



        --// check if item exists and level is enough
        local itemObj = data.ItemsSQL[itemInfo.UniqueId]
        if itemObj == nil then
            data.EquippingItemsSQL[thatSlot] = nil
            continue
        end

        local whiteList = { "Accessory", "Active", "Consumable", "Weapon" }
        if not table.find(whiteList, ItemLib:GetItemInfo(itemObj.ItemId).Type) then
            data.EquippingItemsSQL[thatSlot] = nil
            continue
        end
        if data.Level < itemObj.Level then
            data.EquippingItemsSQL[thatSlot] = nil
            continue
        end
    end



    --// check valid weapon equipping
    if next(data.ItemsSQL) == nil then
        local itemUniqueIdForEmptyWeapon = HttpService:GenerateGUID(false)
        local class = data.Class or "Chain" :: string

        local weaponId = {
            Chain = "WoodenSword",
            Burst = "WoodenBow",
            Flow = "WoodenStaff"
        }

        data.ItemsSQL[itemUniqueIdForEmptyWeapon] = {
            ItemId = weaponId[class] or "WoodenSword",
            Amount = 1,
            UniqueId = itemUniqueIdForEmptyWeapon,
            Level = 1,
            IsV2ItemStat = true,
            ItemStat = ServerLib:GiveRandomStatForItem(weaponId[class] or "WoodenSword")
        }
    end

    local function _checkIfHasWeaponEquipped()
        local weaponFound = nil
        for _, itemInfo: table in data.ItemsSQL do
            if ItemLib:GetItemInfo(itemInfo.ItemId).Type == "Weapon" then
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

    --// TODO: give main1 quest
    -- if next(data.QuestsV2) == nil then
    --     data.QuestsV2.Main1 = {
    --         Id = "Main1",
    --         QuestState = "Started",
    --         ObjectiveProgress = {}
    --     }
    -- end


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

    if shouldReset then
        data.PerkPoints = shouldPoint
        data.VITPoints = 0
        data.INTPoints = 0
        data.STRPoints = 0
        data.DEXPoints = 0
    end


    return data
end


function PlayerLib:_ListenStatLimitTracker()
    local plr = self.Player :: Player

    local totalBin = {}


    local function __trackWhichStat(statAttr: string)
        if plr:GetAttribute(statAttr) == nil then
            warn("Invalid base stat: "..statAttr)
            return
        end
        if PlayerLimitsTemplate[statAttr.."Min"] == nil or PlayerLimitsTemplate[statAttr.."Max"] == nil then
            warn("Invalid limit stat: "..statAttr)
            return
        end

        local function __track()
            local base = plr:GetAttribute(statAttr) :: any
            local limitMin = PlayerLimitsTemplate[statAttr.."Min"] :: number
            local limitMax = PlayerLimitsTemplate[statAttr.."Max"] :: number


            if base < limitMin then
                plr:SetAttribute(statAttr, limitMin)
            end
            if base > limitMax then
                plr:SetAttribute(statAttr, limitMax)
            end
        end
        totalBin["Attr-"..statAttr] = __track
    end
    __trackWhichStat("Gold")
    __trackWhichStat("Astra")
    __trackWhichStat("Level")


    self.Add(HarukaLib:Hydrate(plr, totalBin))
end


return PlayerLib
