
repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


local CollectionService = game:GetService("CollectionService")
local DSS = game:GetService("DataStoreService")
local Lighting = game:GetService("Lighting")
local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")


export type AbyssWorldLibClass = {
    Funcs: { () -> nil },
    ListenFuncs: { () -> nil },

    Started: boolean,
    AbyssId: number,
    AbyssStartTime: number,

    Init: (self: AbyssWorldLibClass) -> nil,


    GiveLoot: (self: AbyssWorldLibClass) -> nil,
    UpdateSpeedrunTime: (self: AbyssWorldLibClass, runTime: number) -> nil,
    ApplyModifier: (self: AbyssWorldLibClass) -> nil
}


local AbyssWorldLib = {} :: AbyssWorldLibClass
AbyssWorldLib.Funcs = {}
AbyssWorldLib.ListenFuncs = {}


local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)

local AbyssBook = require(ReplicatedStorage.HarukaShared.Library.AbyssBook)
local ItemBook = require(ReplicatedStorage.HarukaShared.Library.ItemBook)


if not workspace:GetAttribute("AbyssId") then return nil end


local abyssMobsContainer = workspace.Enemies:FindFirstChild("_ABYSS_TEAM") :: Folder
if not abyssMobsContainer then
    error("[AbyssLib] _ABYSS_TEAM folder not found in Enemies folder")
    return nil
end


local abyssAirwall = workspace.MapComponents:FindFirstChild("_AbyssAirwall") :: BasePart
if not abyssAirwall then
    error("[AbyssLib] _AbyssAirwall folder not found in MapComponents folder")
    return nil
end



local abyssSpeedrunDatastore = DSS:GetOrderedDataStore(require(ServerScriptService.ABYSS_DS_VERSION))


--// helper functions

local function _notifyFireAll(text: string)
    Events.CreateNotify_S.FireList(CollectionService:GetTagged("PlayerEntity"), text)
end



local wait = task.wait


function AbyssWorldLib:Init()
    Promise.try(AbyssWorldLib.Funcs[1]):await()

    for _, func: () -> nil in AbyssWorldLib.ListenFuncs do
        task.spawn(func)
    end
end


--// Private functions


function AbyssWorldLib:GiveLoot()
    for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
        Promise.try(function()
            for _ = 1, 3 do
                Events.PlaySound_S.Fire(player, SoundService.SFXs.LootDropped)

                local result = HarukaLib:RollLoot(ItemBook:GetAllMaterialsLoot())

                ServerLib:GiveItemDrop(player, result, Random.new():NextInteger(9, 13) * AbyssWorldLib.AbyssId)
                wait(0.15)
            end
            if AbyssWorldLib.AbyssId < 5 then return end


            local devLuck = workspace:GetAttribute("__SecretLuck")
            devLuck = devLuck or 1

            wait(1)
            local rareDrop = HarukaLib:RollLoot({
                Dawn = 1,
                None = 100
            }, devLuck)
            if rareDrop == "Dawn" then
                Events.PlaySound_S.Fire(player, SoundService.SFXs.LootDropped)
                Events.Abyss_RareDropObtained_S.Fire(player)

                ServerLib:GiveItemDrop(player, "Dawnbreak", 1)
                ServerBindables.RToSendMsgToDiscord:Fire(player.Name.. " has obtained a rare drop with 1% chance! Dawnbreak!")
            end
        end)
    end
end
function AbyssWorldLib:UpdateSpeedrunTime(runTime: number)
    for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
        local userIdStr = tostring(player.UserId)
        local currentRecord = abyssSpeedrunDatastore:GetAsync("Player_"..userIdStr)

        if currentRecord and currentRecord <= runTime then
            Events.CreateNotify_S.Fire(player, "You haven't beaten the previous record.")
            continue
        end

        Events.CreateNotify_S.Fire(player, "Your record has been updated!")
        ServerBindables.RToUpdateLeaderboardRank:Fire("Player_"..userIdStr, runTime, "Abyss")
    end
end




table.insert(AbyssWorldLib.Funcs, function()
    repeat wait(0.5) until Players:FindFirstChildOfClass("Player")

    local player = Players:FindFirstChildOfClass("Player")
    local abyssHashMap = MemoryStoreService:GetHashMap("_AbyssTeleportData")

    local abyssId = 1
    local success, _ = pcall(function()
        abyssId = abyssHashMap:GetAsync("Player_"..player.UserId)
    end)
    if not success then
        abyssId = 1
    end
    abyssId = abyssId or 1


    AbyssWorldLib.AbyssId = abyssId
    workspace:SetAttribute("AbyssLevelId", abyssId)
    workspace:SetAttribute("AbyssTime", 0)


    local totalMobs = abyssMobsContainer:GetChildren() :: { BasePart }
    local index = 1
    for _, mobInfo: AbyssBook.AbyssTeamJSON in AbyssBook.TeamConfigs do
        if not totalMobs[index] then break end

        local locator = totalMobs[index] :: BasePart

        locator.Name = mobInfo.MobId
        locator:SetAttribute("Level", mobInfo.Level)
        locator:SetAttribute("EnvironmentBonus", abyssId)

        locator:SetAttribute("_RESPAWN_SYMBOL", true)

        index += 1
    end

    RunService.Stepped:Wait()
    for _, locator: BasePart in totalMobs do
        if locator.Name == "GreenSlime" then
            locator:Destroy()
        end
    end

    workspace:SetAttribute("AbyssStarted", false)


    --// modifiers
    local modifiers = HarukaLib.TableUtils.Cut(AbyssBook.Modifiers, abyssId) :: { string }
    if table.find(modifiers, "BurnInflict") then
        workspace:SetAttribute("_Modifier_BurnInflict", true)
    end
    if table.find(modifiers, "BlurEffect") then
        local blurEffect = Instance.new("BlurEffect")
        blurEffect.Enabled = true
        blurEffect.Parent = Lighting
    end
end)





table.insert(AbyssWorldLib.ListenFuncs, function()
    Events.Abyss_StartAbyss_C.SetCallback(function()
        if AbyssWorldLib.Started then return end
        AbyssWorldLib.Started = true

        _notifyFireAll("CHALLENGE STARTED!")
        workspace:SetAttribute("AbyssStarted", true)


        AbyssWorldLib.AbyssStartTime = DateTime.now().UnixTimestamp

        abyssAirwall:Destroy()
    end)
end)



table.insert(AbyssWorldLib.ListenFuncs, function()
    HarukaLib.Clock(1, function()
        if not workspace:GetAttribute("AbyssStarted") then return end
        if workspace:GetAttribute("AbyssFinished") then return end

        HarukaLib:AddAttr(workspace, "AbyssTime", 1)
    end)
end)



table.insert(AbyssWorldLib.ListenFuncs, function()
    repeat wait(1) until #abyssMobsContainer:GetChildren() <= 0


    workspace:SetAttribute("AbyssFinished", true)
    task.delay(1, AbyssWorldLib.GiveLoot, AbyssWorldLib)


    --// count speedrun if it's f6
    if AbyssWorldLib.AbyssId == 6 and AbyssWorldLib.AbyssStartTime then
        local now = DateTime.now().UnixTimestamp
        local runTime = now - AbyssWorldLib.AbyssStartTime


        if runTime <= 5 then
            _notifyFireAll("Invalid record! (Less than 5 seconds)")
            return
        end

        _notifyFireAll("Updating your record...please wait...")
        AbyssWorldLib:UpdateSpeedrunTime(runTime)
    end
end)




table.insert(AbyssWorldLib.ListenFuncs, function()
    Events.Abyss_AfterEndAction_S.SetCallback(function(plr: Player, actionId: string)
        if not actionId then return end


        if actionId == "Leave" then
            Events.CreateFSNotify_S.Fire(plr, "Teleporting back to Mainworld...", 999)

            local teleportOptions = Instance.new("TeleportOptions")
            local slotInfo = {
                [plr.Name] = plr:GetAttribute("SlotChosen")
            }
            teleportOptions:SetTeleportData({
                FromAbyss = true,
                SlotIds = slotInfo
            })
            TeleportService:TeleportAsync(
                AssetBook.PlaceIds[tostring(game.GameId)].Mainworld,
                { plr },
                teleportOptions
            )

        elseif actionId == "Restart" then
            ServerBindables.RToChallengeAbyss:Fire(plr, AbyssWorldLib.AbyssId)
        end
    end)
end)

AbyssWorldLib:Init()