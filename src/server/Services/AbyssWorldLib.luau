local AnalyticsService = game:GetService("AnalyticsService")
local CollectionService = game:GetService("CollectionService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")


local AbyssWorldLib = {}

local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)

local AbyssTeambook = require(ReplicatedStorage.HarukaShared.Library.AbyssTeambook)
local ItemBook = require(ReplicatedStorage.HarukaShared.Library.ItemBook)


if not workspace:GetAttribute("AbyssId") then return nil end


local wait = task.wait


function AbyssWorldLib:Init()
    for funcId: string, func: (self) -> nil in AbyssWorldLib do
        if string.find(funcId, "_Do") and typeof(func) == "function" then
            Promise.try(func, self):catch(function(err)
                warn(tostring(err))
            end):await()
        end
    end

    for funcId: string, func: (self) -> nil in AbyssWorldLib do
        if string.find(funcId, "_Listen") and typeof(func) == "function" then
            task.spawn(func, self)
        end
    end
end


--// Private functions


function AbyssWorldLib:_DoInitAbyssInfo()
    if not workspace:GetAttribute("AbyssId") then return end

    repeat wait() until Players:FindFirstChildOfClass("Player")

    local player = Players:FindFirstChildOfClass("Player")
    local abyssSortedMap = MemoryStoreService:GetSortedMap("AbyssTeleportData")

    local abyssId = 1
    local success, _ = pcall(function()
        abyssId = abyssSortedMap:GetAsync("AbyssChallenge_"..player.UserId)
    end)
    if not success then
        abyssId = 1
    end
    abyssId = abyssId or 1


    self.AbyssId = abyssId


    local folder = workspace.Enemies:FindFirstChild("_DUNGEON_BOSS") :: Folder
    if not folder then
        warn("Did you forget to add the _BOSS folder to the Enemies folder?")
        return
    end

    workspace:SetAttribute("AbyssLevelId", abyssId)

    local totalMobs = folder:GetChildren() :: { BasePart }
    local index = 1
    for mobId: string, mobInfo in AbyssTeambook[abyssId].Team do
        if not totalMobs[index] then break end

        local locator = totalMobs[index] :: BasePart

        locator.Name = mobId
        locator:SetAttribute("Level", mobInfo.Level)
        locator:SetAttribute("EnvironmentBonus", mobInfo.EnvironmentBonus)

        locator:SetAttribute("NoRandomName", true)
        locator:SetAttribute("_RESPAWN_SYMBOL", true)

        index += 1
    end

    workspace:SetAttribute("DungeonStarted", false)
end





function AbyssWorldLib:_ListenAbyssRequestsTracker()
    Events.DUNGEON_RequestToStartDungeon.SetCallback(function(plr: Player)
        workspace:SetAttribute("DungeonStarted", true)

        Events.CreateCenterNotify.FireList(CollectionService:GetTagged("PlayerEntity"), "CHALLENGE STARTED!", true)
        Events.DUNGEON_StartDungeon.FireList(CollectionService:GetTagged("PlayerEntity"))

        workspace.MapComponents:FindFirstChild("_DungeonStartAirWall", true):Destroy()


        local clockDisconnect = nil
        workspace:SetAttribute("DungeonLeftTime", 0)

        clockDisconnect = HarukaLib.Clock(1, function()
            if workspace:GetAttribute("DungeonFinished") then return end

            HarukaLib:AddAttr(workspace, "DungeonLeftTime", 1)
        end)


        repeat wait() until workspace:GetAttribute("DungeonFinished")

        if clockDisconnect then clockDisconnect() end
    end)
end




function AbyssWorldLib:_ListenBossEndTracker()
    local folder = workspace.Enemies:FindFirstChild("_DUNGEON_BOSS") :: Folder
    if not folder then
        warn("Did you forget to add the _BOSS folder to the Enemies folder?")
        return
    end

    repeat wait(1) until #folder:GetChildren() <= 0
    Events.DUNGEON_EndDungeon.FireList(CollectionService:GetTagged("PlayerEntity"))


    workspace:SetAttribute("DungeonFinished", true)


    --// record their completion time
    Promise.try(function()
        if not workspace:GetAttribute("AbyssId") then return end
        if not workspace:GetAttribute("AbyssLevelId") then return end
        if workspace:GetAttribute("AbyssLevelId") <= 5 then return end
        if workspace:GetAttribute("DungeonLeftTime") <= 0 then return end

        for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
            ServerBindables.RToUpdateLeaderboardRank:Fire("Player_"..player.UserId, workspace:GetAttribute("DungeonLeftTime"), "SkyTower")
        end
    end)


    wait(1)
    for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
        Promise.try(function()
            for _ = 1, 3 do
                Events.PlaySound.Fire(player, SoundService.SFXs.LootDropped)

                local result = HarukaLib:RollLoot(ItemBook:GetAllMaterialsLoot())

                ServerLib:GiveItemDrop(player, result, self.AbyssId * 2)
                wait(0.15)
            end

            wait(0.5)
            local weaponDrop = HarukaLib:RollLoot(ItemBook:GetAllRareWeaponsLoot())
            if weaponDrop ~= "None" then
                local itemInfo = ItemBook:GetItemInfo(weaponDrop)

                ServerLib:GiveItemDrop(player, weaponDrop, 1)

                Events.CreateSystemNotify.FireList(
                    CollectionService:GetTagged("PlayerEntity"),
                    `<red>{player.Name} has looted {itemInfo.Name}!</font>`
                )

                pcall(function()
                    AnalyticsService:LogCustomEvent(player, "PlayerGotLegFromAbyss", 1)
                end)
            end
        end)
    end


    wait(6)
    Events.CreateFSNotify.FireList(CollectionService:GetTagged("PlayerEntity"), "Teleporting back to Mainworld...", 999)


    local teleportOptions = Instance.new("TeleportOptions")

    local slotInfo = {}
    for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
        slotInfo[player.Name] = player:GetAttribute("SlotChosen")
    end

    teleportOptions:SetTeleportData({
        FromAbyss = true,
        SlotIds = slotInfo
    })

    wait(1)
    TeleportService:TeleportAsync(AssetBook.PlaceIds.Mainworld, Players:GetPlayers(), teleportOptions)
end



return AbyssWorldLib
