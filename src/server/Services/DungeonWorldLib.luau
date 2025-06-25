
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")


local DungeonWorldLib = {}

local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)

local AbyssTeambook = require(ReplicatedStorage.HarukaShared.Library.AbyssTeambook)
local ItemBook = require(ReplicatedStorage.HarukaShared.Library.ItemBook)


local wait = task.wait


function DungeonWorldLib:Init()
    for funcId: string, func: (self) -> nil in DungeonWorldLib do
        if string.find(funcId, "_Do") and typeof(func) == "function" then
            Promise.try(func, self):catch(function(err)
                warn(tostring(err))
            end):await()
        end
    end

    for funcId: string, func: (self) -> nil in DungeonWorldLib do
        if string.find(funcId, "_Listen") and typeof(func) == "function" then
            task.spawn(func, self)
        end
    end
end


--// Private functions


function DungeonWorldLib:_DoInitDungeons()
    if not workspace:GetAttribute("DungeonId") then return end

    workspace:SetAttribute("DungeonStarted", false)


    local dungeonLevels = workspace.Enemies:FindFirstChild("_DUNGEON")
    if not dungeonLevels then
        warn("Did you forget to add the _DUNGEON folder to the Enemies folder?")
        return
    end


    --// Init signals
    local signalFolder = Instance.new("Folder")
    signalFolder.Name = "DungeonSignals"
    signalFolder.Parent = ServerStorage

    for _, folder: Folder in dungeonLevels:GetChildren() do
        local BE = Instance.new("BindableEvent")
        BE.Name = folder.Name
        BE.Parent = signalFolder
    end

    --// Init dungeons
    local completedSignals = {}

    HarukaLib.Clock(0.1, function()
        for _, folder: Folder in dungeonLevels:GetChildren() do
            if #folder:GetChildren() <= 0 and not completedSignals[folder.Name] then
                completedSignals[folder.Name] = true

                signalFolder[folder.Name]:Fire()
                workspace:SetAttribute("_DUNGEON_"..folder.Name.."_PASSED", true)
            end
        end
    end)
end


function DungeonWorldLib:_DoInitDungeonPortals()
    for _, portal: BasePart in CollectionService:GetTagged("DungeonPortalEntity") do
        local eff = ReplicatedStorage.Packages.Effects.Portal:Clone() :: BasePart
        eff.CFrame = portal.CFrame
        eff.Parent = workspace.MapComponents.DungeonPortals

        portal.Transparency = 1
    end
    if not workspace.Maps:FindFirstChild("_DUNGEON_LEVELS") then return end


    for _, map: Folder in workspace.Maps._DUNGEON_LEVELS:GetChildren() do
        map:SetAttribute("OriName", map.Name)
        map.Name = "_HASH_"..map.Name
    end
end



function DungeonWorldLib:_ListenDungeonRequestsTracker()
    Events.DUNGEON_RequestToStartDungeon.SetCallback(function(plr: Player)
        workspace:SetAttribute("DungeonStarted", true)

        Events.CreateCenterNotify.FireList(CollectionService:GetTagged("PlayerEntity"), "DUNGEON STARTED!", true)
        Events.CreateNotify.FireList(CollectionService:GetTagged("PlayerEntity"), `{plr.Name} Started the Dungeon!`)
        Events.DUNGEON_StartDungeon.FireList(CollectionService:GetTagged("PlayerEntity"))


        if workspace.Maps:FindFirstChild("_DUNGEON_LEVELS") then
            for _, map: Folder in workspace.Maps._DUNGEON_LEVELS:GetChildren() do
                map.Name = map:GetAttribute("OriName")
            end
        end


        workspace.MapComponents:FindFirstChild("_DungeonStartAirWall", true):Destroy()


        if not workspace:GetAttribute("AbyssId") then
            workspace:SetAttribute("DungeonLeftTime", 60 * 11)

            HarukaLib.Clock(1, function()
                HarukaLib:AddAttr(workspace, "DungeonLeftTime", -1)
            end)
        else
            workspace:SetAttribute("DungeonLeftTime", 0)

            HarukaLib.Clock(1, function()
                HarukaLib:AddAttr(workspace, "DungeonLeftTime", 1)
            end)
        end
    end)
end



function DungeonWorldLib:_ListenDungeonStageAirwallDestroyTracker()
    if not workspace:GetAttribute("AbyssId") then
        HarukaLib.Clock(1, function()
            for _, part: BasePart in CollectionService:GetTagged("DungeonStageWallEntity") do
                if workspace:GetAttribute("_DUNGEON_"..part.Name.."_PASSED") then
                    part:Destroy()
                end
            end
        end)

        repeat wait(1) until #CollectionService:GetTagged("DungeonStageWallEntity") <= 0

        Events.DUNGEON_StartBossFight.FireList(CollectionService:GetTagged("PlayerEntity"))
    end
end


function DungeonWorldLib:_ListenBossEndTracker()
    local folder = workspace.Enemies:FindFirstChild("_DUNGEON_BOSS") :: Folder
    if not folder then
        warn("Did you forget to add the _BOSS folder to the Enemies folder?")
        return
    end

    repeat wait(1) until #folder:GetChildren() <= 0
    Events.DUNGEON_EndDungeon.FireList(CollectionService:GetTagged("PlayerEntity"))


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

                ServerLib:GiveItemDrop(player, result, 5)

                if result == "VolatileGem" then
                    Events.CreateSystemNotify.FireList(
                        CollectionService:GetTagged("PlayerEntity"),
                        `<red>{player.Name} has looted {result}!</font>`
                    )
                end
                wait(0.15)
            end

            wait(0.5)
            local weaponDrop = HarukaLib:RollLoot(ItemBook:GetAllRareWeaponsLoot())
            if weaponDrop ~= "None" then
                local itemInfo = ItemBook:GetItemInfo(weaponDrop)

                Events.CreateSystemNotify.FireList(
                    CollectionService:GetTagged("PlayerEntity"),
                    `<red>{player.Name} has looted {itemInfo.Name}!</font>`
                )
            end
        end)
    end


    wait(10)
    TeleportService:TeleportAsync(AssetBook.PlaceIds.Mainworld, Players:GetPlayers())
end



function DungeonWorldLib:_ListenDungeonActivationsTracker()
    ServerBindables.RToActivateDungeonSystem:Connect(function(abyssId: number)
        if workspace:GetAttribute("AbyssId") then
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
        end
    end)
end


return DungeonWorldLib
