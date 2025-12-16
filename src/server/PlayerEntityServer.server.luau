
repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")

local CollectionService = game:GetService("CollectionService")
local AnalyticsService = game:GetService("AnalyticsService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")


local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)
local HarukaDatastore = require(ServerScriptService.HarukaServer.Shared.HarukaDatastore)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local ItemBook = require(ReplicatedStorage.HarukaShared.Library.ItemBook)
local QuestBook = require(ReplicatedStorage.HarukaShared.Library.QuestBook)
local PlayerProfileLib = require(ServerScriptService.HarukaServer.Services.PlayerProfileLib)
local QuestLib = require(ServerScriptService.HarukaServer.Services.QuestLib)


local PlayerTemplate = require(ServerScriptService.HarukaServer.Library.PlayerTemplate)


type PlayerLibClass = {
    __index: PlayerLibClass,

    new: (player: Player) -> PlayerLibClass,

    Destroy: (self: PlayerLibClass) -> nil,
    Init: (self: PlayerLibClass) -> nil,

    _Remove: (self: PlayerLibClass) -> nil,
    _SaveData: (self: PlayerLibClass) -> nil,
    RemoveMapComponents: (self: PlayerLibClass) -> nil,

    Player: Player,
    UniqueId: string,
    ProfileObj: PlayerProfileLib.PlayerProfileLibClass,
    Slot: "Slot1" | "Slot2" | "Slot3",

    Add: <T>(item: T) -> T,
    Empty: () -> nil,
}



local PlayerLib = {} :: PlayerLibClass
PlayerLib.__index = PlayerLib


local RankBook = require(ReplicatedStorage.HarukaShared.Library.RankBook)


local DS_Version = require(ServerScriptService.DS_VERSION)


local profileStoreMain = HarukaDatastore.GetStore(
    DS_Version.Id,
    PlayerTemplate
)

local totalPlayersJoined = 0
local allPlayerObjPool = {}


local wait = task.wait


local attrWhiteList = {}
for attr, val in HarukaLib.TableUtils.DeepCopy(PlayerTemplate).Slot1.Attrs do
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
Events.Titlescreen_SlotActions_C.On(function(plr: Player, netData)
    if not netData.ActionId then return end
    if not netData.SlotId then return end


    if netData.ActionId ~= "Play" then return end

    local playerObj = allPlayerObjPool[plr:GetAttribute("HarukaUniqueId")]
    if not playerObj then
        plr:Kick("Failed to find player object, please report this issue to the developer!")
        return
    end

    local self = playerObj
    if self.Slot then return end


    --// Load in datastore
    Promise.new(function(resolve, reject)
        local slotChosen = netData.SlotId or "Slot1"
        local profile = self.ProfileObj.Profile


        --// start to load in
        local slot = slotChosen
        local data = profile.Data[slot].Attrs :: PlayerTemplate.PlayerDataJSON

        self.Slot = slot
        plr:SetAttribute("SlotChosen", slot)

        --// update join time
        data.LastJoinedDateTime = DateTime.now():ToIsoDate()

        --// validate
        local validatedMainData = self.ProfileObj:_ValidateMainData(profile.Data)
        if validatedMainData == nil then reject() return end

        profile.Data = validatedMainData


        local validatedData = self.ProfileObj:_ValidateSaveData(validatedMainData[slot].Attrs)
        if validatedData == nil then reject() return end

        profile.Data[slot].Attrs = validatedData


        --// load validated data
        for attr: string, val: any in validatedData do
            if not table.find(attrWhiteList, attr) then continue end

            plr:SetAttribute(attr, val)
        end


        local itemFolder, equippingFolder, questFolder, settingsFolder, talentFolder =
            Instance.new("Folder"),
            Instance.new("Folder"),
            Instance.new("Folder"),
            Instance.new("Configuration"),
            Instance.new("Folder")

        itemFolder.Name = "Items"
        equippingFolder.Name = "EquippingItems"
        questFolder.Name = "Quests"
        settingsFolder.Name = "CriRPGSettings"
        talentFolder.Name = "Talents"

        itemFolder.Parent = plr
        equippingFolder.Parent = plr
        questFolder.Parent = plr
        settingsFolder.Parent = plr
        talentFolder.Parent = plr


        for _, itemInfo: PlayerTemplate.PlayerItemDataJSON in validatedData.ItemsSQL do
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
            itemVal:SetAttribute("ItemStat", itemInfo.ItemStat)
            itemVal:SetAttribute("IsFav", itemInfo.IsFav or false)
            itemVal:SetAttribute("IsLocked", itemInfo.IsLocked or false)

            itemVal.Parent = itemFolder
        end
        for thatSlot: string, itemInfo: PlayerTemplate.PlayerEquippingItemDataJSON in validatedData.EquippingItemsSQL do
            local itemVal = Instance.new("StringValue")
            itemVal.Name = thatSlot
            itemVal.Value = itemInfo.ItemId

            itemVal:SetAttribute("HarukaUniqueId", itemInfo.UniqueId)

            itemVal.Parent = equippingFolder
        end


        QuestLib:InitPlayer(plr)


        local isAbyss = workspace:GetAttribute("AbyssId")
        local isDungeon = workspace:GetAttribute("DungeonId")

        if not isAbyss and not isDungeon then
            QuestLib:LoadSavedTable(plr, validatedData.QuestsV3)
            self.Add(function()
                QuestLib:StopTrackingPlayer(plr)
            end)
        end


        for settingsId: string, settingsVal: any in validatedMainData.Settings do
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
        for _, talentId: string in validatedData.Talents do
            local talentVal = Instance.new("BoolValue")
            talentVal.Name = talentId
            talentVal.Value = true

            talentVal.Parent = talentFolder
        end


        --// apply player rank in another thread
        Promise.try(function()
            local playerUID = tostring(plr.UserId)

            plr:SetAttribute("Rank", 0)

            local hasCustomRole = false
            if RankBook.CustomRoleInfo[playerUID] then
                hasCustomRole = true

                plr:SetAttribute("Role", RankBook.CustomRoleInfo[playerUID].Role)
            end

            local rank = plr:GetRankInGroupAsync(16912246)
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

            local rank = plr:GetRankInGroupAsync(16912246)
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

        end):catch(function() end)


        --// load in player badges
        ServerBindables.RToCheckPlayerBadges:Fire(plr)


        --// load in player gamepass and dev products
        Promise.try(function()
            for gamepass: string, gamepassId: number in AssetBook.GamepassIds do
                Promise.try(function()
                    if profile.Data.GamepassPurchaseLogs[gamepass] then return end

                    local ownedGamepass = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, gamepassId)
                    if not ownedGamepass then return end

                    local gamepassInfo = MarketplaceService:GetProductInfoAsync(gamepassId, Enum.InfoType.GamePass)
                    if not gamepassInfo then return end
                    if not gamepassInfo.IsForSale then return end

                    profile.Data.GamepassPurchaseLogs[gamepass] = {
                        PurchaseDateTime = DateTime.now():ToIsoDate(),
                        Purchased = true,
                        PurchasedPrice = gamepassInfo.PriceInRobux
                    }

                end):catch(function() end)
            end


            PlayerProfileLib.CalDonationAndSave(profile, plr)
        end)


        --// Alpha Player badge
        ServerLib:GiveBadge(3358503633424175, plr)



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

        self.Add(HarukaLib.Clock(77, function()
            self.ProfileObj:UpdateDonationRank()
        end, true))

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
Events.Titlescreen_SlotActions_C.On(function(plr: Player, data)
    if not data.ActionId then return end
    if not data.SlotId then return end

    if data.ActionId ~= "Erase" then return end


    Events.CreateFSNotify_S.Fire(plr, "Erasing your save file...", 3)


    local playerObj = allPlayerObjPool[plr:GetAttribute("HarukaUniqueId")]
    if not playerObj then
        warn("[Data Erase] Player object not found when trying to erase save file.")
        Events.CreateNotify_S.Fire(plr, "Error occurred, please try again later?")
        return
    end
    if not playerObj.ProfileObj.Profile then
        warn("[Data Erase] Profile not found when trying to erase save file.")
        Events.CreateNotify_S.Fire(plr, "Error occurred, please try again later.")
        return
    end


    for attr, value in HarukaLib.TableUtils.DeepCopy(PlayerTemplate).Slot1.Attrs do
        playerObj.ProfileObj.Profile.Data[data.SlotId].Attrs[attr] = value
    end

    local profileContainer = plr.ProfileContainer :: Folder
    for attr, val in HarukaLib.TableUtils.DeepCopy(PlayerTemplate).Slot1.Attrs do
        if not table.find(attrWhiteList, attr) then continue end

        profileContainer:SetAttribute(data.SlotId.."_"..attr, val)
    end
    if profileContainer:FindFirstChild(data.SlotId.."_Weapon1") then
        profileContainer[data.SlotId.."_Weapon1"].Value = "WoodenSword"
    end


    Events.CreateFSNotify_S.Fire(plr, "Save file erased!", 2)
end)
Events.Titlescreen_SlotMiddler_C.SetCallback(function(plr: Player, data)
    if not data.SlotId then return end
    if data.Favorited == nil then return end
    if data.MobileConfigured == nil then return end

    local playerObj = allPlayerObjPool[plr:GetAttribute("HarukaUniqueId")]
    if not playerObj then return end

    local profile = playerObj.ProfileObj.Profile
    local slot = data.SlotId :: "Slot1"

    if data.Favorited then
        profile.Data[slot].Attrs.FavActionDone = data.Favorited
    end
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
        wait(0.5)
        if not plr then break end
        if not plr.Parent then break end
        if profile ~= nil then break end


        Promise.new(function(resolve, reject)
            profile = profileStoreMain:CreateProfileAsync("Player_"..plr.UserId, false)

            if profile == nil then
                reject("Failed to fetch profile")
                return
            end


            --// transfer data!! (V0.5.5)
            if not profile._IsTransferred then
                local success, result = profile:TransferDataAsync(DS_Version.OldId, "Player_"..plr.UserId)
                if success then
                    profile._IsTransferred = true
                    profile:SaveProfileAsync()
                else
                    warn("[Data Migration] Failed to transfer data from old datastore to new one!")
                    warn(tostring(result))

                    pcall(function()
                        AnalyticsService:LogCustomEvent(plr, "PlayerDataTransferFailed", 1)
                    end)
                    plr:Kick("[Code 101] Failed to transfer data, please try again or contact us in community!")

                    resolve("Failed to transfer data")
                    return
                end
            end


            resolve(true)
        end):timeout(6):catch(function(err)
            if Promise.Error.isKind(err, Promise.Error.Kind.TimedOut) then
                Events.CreateNotify_S.Fire(plr, "Roblox server is running slower than usual, we're trying to load...")
            else
                Events.CreateNotify_S.Fire(plr, "Roblox server is handling requests slowly, we're trying to load...")
                if RunService:IsStudio() then
                    warn(tostring(err))
                end
            end
        end):await()

        if profile == nil then
            profileFailedTimes += 1
        end
    end

    wait(0.5)
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


    if plr.Parent ~= Players then return end


    local profileObj = PlayerProfileLib.new(plr, profile)
    self.ProfileObj = profileObj


    --// Load in datastore
    profileObj:Init()
    self.Add(profileObj)


    local profileContainer = Instance.new("Folder")
    profileContainer.Name = "ProfileContainer"
    profileContainer.Parent = plr


    Promise.new(function(resolve)
        for i = 1, 3 do
            local data = self.ProfileObj:_ValidateSaveData(profile.Data["Slot"..i].Attrs)

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



function PlayerLib:Destroy()
    allPlayerObjPool[self.UniqueId] = nil

    self:RemoveMapComponents()
    self.Empty()


    local success, err = pcall(self._SaveData, self)
    if not success then
        warn(err)
    end
end


--// Private functions


function PlayerLib:_SaveData()
    if not self.ProfileObj then return end
    if not self.ProfileObj.Profile then return end
    if not self.Slot then return end
    if self.Player:GetAttribute("Haruka_DataLocked") then return end

    local profileAttrs = self.ProfileObj.Profile.Data[self.Slot].Attrs :: { any }
    local nowAttrs = self.Player:GetAttributes()


    for k: string, val: any in profileAttrs do
        if typeof(val) == "table" then continue end
        if nowAttrs[k] == nil then continue end

        profileAttrs[k] = nowAttrs[k]
    end


    local items = self.Player.Items :: Folder
    local equippingItems = self.Player.EquippingItems :: Folder
    local criSettings = self.Player.CriRPGSettings :: Configuration
    local talents = self.Player.Talents :: Folder

    local itemSQL = {}
    local equippingItemsSQL = {}
    local criSettingsSQL = {}
    local talentsSQL = {}

    for _, item: IntConstrainedValue in items:GetChildren() do
        if item:IsA("IntConstrainedValue") then
            local uniqueId = item:GetAttribute("HarukaUniqueId") :: string
            local amount = item.Value

            if not uniqueId or not amount then
                continue
            end
            if amount <= 0 then continue end

            itemSQL[uniqueId] = {
                ItemId = item.Name,
                Amount = amount,
                UniqueId = uniqueId,
                ItemStat = item:GetAttribute("ItemStat"),
                IsFav = item:GetAttribute("IsFav"),
                IsLocked = item:GetAttribute("IsLocked")
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
    for _, symbol: any in criSettings:GetChildren() do
        criSettingsSQL[symbol.Name] = symbol.Value
    end
    for _, symbol: BoolValue in talents:GetChildren() do
        table.insert(talentsSQL, symbol.Name)
    end

    local success, result = pcall(function()
        local isAbyss = workspace:GetAttribute("AbyssId")
        local isDungeon = workspace:GetAttribute("DungeonId")

        if not isAbyss and not isDungeon then
            --- im not 100% sure if this will work correctly, better pcall it
            local questData = QuestLib:ExportDataTable(self.Player)
            if questData then
                profileAttrs.QuestsV3 = questData
            end
        end
    end)
    if not success then
        warn(result)
    end


    profileAttrs.ItemsSQL = itemSQL
    profileAttrs.EquippingItemsSQL = equippingItemsSQL
    profileAttrs.Talents = talentsSQL

    self.ProfileObj.Profile.Data.Settings = criSettingsSQL
    self.ProfileObj.Profile:SaveProfileAsync()

    PlayerProfileLib.CalDonationAndSave(self.ProfileObj.Profile, self.Player)
end



function PlayerLib:RemoveMapComponents()
    local funcs = {
        function()
            for _, chest: Model in CollectionService:GetTagged("ChestEntity") do
                chest:SetAttribute("Receiver_"..self.Player.Name, nil)
            end
        end,

        function()
            local party = workspace.MapComponents.PartyHolder:FindFirstChild(self.Player.Name, true) :: ObjectValue?
            if not party then return end

            ServerBindables.PartyInvite:Fire(self.Player, "PartyLeave", self.Player.Name)
        end,
    }
    for i = 1, #funcs do
        pcall(funcs[i])
    end
end



local function initPlayer(player: Player)
    if #Players:GetPlayers() > Players.MaxPlayers then
        player:Kick("Server is full")
        return
    end
    if workspace:GetAttribute("Haruka_ServerLocked") then
        player:Kick("This server is shutting down, please do server hopping or wait for a while.")
        return
    end
    if player.AccountAge < 2 and not RunService:IsStudio() then
        player:Kick("You must be at least 2 days old in Roblox Platform to play!")
        return
    end

    local playerObj = PlayerLib.new(player)
    if playerObj then
        playerObj:Init()
    end
end
for _, player: Player in Players:GetPlayers() do
    Promise.try(initPlayer, player)
end
Players.PlayerAdded:Connect(initPlayer)



workspace:SetAttribute("Haruka_ServerPlayerLibInited", true)