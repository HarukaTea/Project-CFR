
repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


local CollectionService = game:GetService("CollectionService")
local DSS = game:GetService("DataStoreService")
local Lighting = game:GetService("Lighting")
local MemoryStoreService = game:GetService("MemoryStoreService")
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
    Modifiers: { string },

    IsChosenTeleportAction: boolean,

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
        func()
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

            local baseChance = 0.2
            local bonusChance = (AbyssWorldLib.AbyssId - 1) * 0.1
            local bonusChance2 = #AbyssWorldLib.Modifiers * 0.15
            local finalChance = baseChance + bonusChance + bonusChance2
            local finalChanceStr = string.format("%.1f", tostring(finalChance))

            local abyssDropPity = player:GetAttribute("AbyssDropPity") or 0
            local luck = 1
            if abyssDropPity >= 75 then
                luck = 1599400
            end

            wait(1)
            local rareDrop = HarukaLib:RollLoot({
                Dawn = finalChance,
                None = 100 - finalChance
            }, luck)
            if rareDrop == "Dawn" then
                Events.PlaySound_S.Fire(player, SoundService.SFXs.LootDropped)
                Events.Abyss_RareDropObtained_S.Fire(player)

                ServerLib:GiveItemDrop(player, "Dawnbreak", 1)
                ServerBindables.RToSendMsgToDiscord:Fire(player.DisplayName.. "(@".. player.Name.. ") has obtained Dawnbreak with "..finalChanceStr.."% chance!")

                player:SetAttribute("AbyssDropPity", 0)
            else
                HarukaLib:AddAttr(player, "AbyssDropPity", 1)
            end
        end):catch(function(err)
            warn(tostring(err))
        end)
    end
end
function AbyssWorldLib:UpdateSpeedrunTime(runTime: number)
    for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
        local userIdStr = tostring(player.UserId)
        local currentRecord = abyssSpeedrunDatastore:GetAsync("Player_"..userIdStr)

        if currentRecord and currentRecord <= runTime then
            Events.CreateNotify_S.Fire(player, "You haven't beaten the previous record")
            continue
        end

        Events.CreateNotify_S.Fire(player, "Your record has been updated!")
        ServerBindables.RToUpdateLeaderboardRank:Fire("Player_"..userIdStr, runTime, "Abyss")
    end
end




table.insert(AbyssWorldLib.Funcs, function()
    local abyssHashMap = MemoryStoreService:GetHashMap("_AbyssTeleportData_V2")

    local abyssId = 1
    local modifiers = {}
    local privateServerId = game.PrivateServerId
    if privateServerId == "" then
        privateServerId = "Mock12345678"
    end
    privateServerId = string.sub(privateServerId, 1, 8)

    local success, _ = pcall(function()
        local data = abyssHashMap:GetAsync(privateServerId)

        abyssId = data.AbyssId or 1
        modifiers = data.Modifiers or {}
    end)
    if not success then
        abyssId = 1
        modifiers = {}
    end

    AbyssWorldLib.AbyssId = abyssId
    AbyssWorldLib.Modifiers = modifiers

    workspace:SetAttribute("AbyssLevelId", abyssId)
    workspace:SetAttribute("AbyssModifiers", table.concat(modifiers, ","))
    workspace:SetAttribute("AbyssTime", 0)


    local totalMobs = abyssMobsContainer:GetChildren() :: { BasePart }
    local index = 1
    for _, mobInfo: AbyssBook.AbyssTeamJSON in AbyssBook.TeamConfigs[abyssId] do
        if not totalMobs[index] then break end

        local locator = totalMobs[index] :: BasePart

        locator.Name = mobInfo.MobId
        locator:SetAttribute("Level", mobInfo.Level)
        locator:SetAttribute("EnvironmentBonus", 8)

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
    if table.find(modifiers, "BurnInflict") then
        workspace:SetAttribute("_Modifier_BurnInflict", true)
    end
    if table.find(modifiers, "BlurEffect") then
        local blurEffect = Instance.new("BlurEffect")
        blurEffect.Enabled = true
        blurEffect.Size = 10
        blurEffect.Parent = Lighting
    end
end)





table.insert(AbyssWorldLib.ListenFuncs, function()
    Events.Abyss_StartAbyss_C.SetCallback(function(plr: Player)
        if AbyssWorldLib.Started then return end
        AbyssWorldLib.Started = true

        _notifyFireAll(plr.DisplayName.." has started the Abyss!")
        workspace:SetAttribute("AbyssStarted", true)

        AbyssWorldLib.AbyssStartTime = os.time()

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
    if AbyssWorldLib.AbyssId == 5 and #AbyssWorldLib.Modifiers >= 6 and AbyssWorldLib.AbyssStartTime then
        local now = os.time()
        local runTime = now - AbyssWorldLib.AbyssStartTime

        if runTime < 3 then
            _notifyFireAll("Invalid record! (Less than 3 seconds)")
            return
        end

        _notifyFireAll("Updating your record...please wait...")
        AbyssWorldLib:UpdateSpeedrunTime(runTime)
    end
end)




table.insert(AbyssWorldLib.ListenFuncs, function()
    Events.Abyss_AfterEndAction_S.SetCallback(function(plr: Player, actionId: string)
        if not actionId then return end
        if AbyssWorldLib.IsChosenTeleportAction then
            Events.CreateNotify_S.Fire(plr, "Another player has chosen to leave/restart the Abyss")
            return
        end

        AbyssWorldLib.IsChosenTeleportAction = true

        if actionId == "Leave" then
            Events.CreateFSNotify_S.FireList(CollectionService:GetTagged("PlayerEntity"), "Teleporting back to Mainworld...", 999)

            local teleportOptions = Instance.new("TeleportOptions")
            local slotChosen = {}
            for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
                slotChosen[player.Name] = player:GetAttribute("SlotChosen") or "Slot1"
            end
            teleportOptions:SetTeleportData({
                FromAbyss = true,
                SlotChosen = slotChosen
            })

            TeleportService:TeleportAsync(
                AssetBook.PlaceIds[tostring(game.GameId)].Mainworld,
                CollectionService:GetTagged("PlayerEntity"),
                teleportOptions
            )

        elseif actionId == "Restart" then
            ServerBindables.RToChallengeAbyss:Fire(plr, {
                AbyssId = AbyssWorldLib.AbyssId,
                Modifiers = AbyssWorldLib.Modifiers,
                ["Players"] = CollectionService:GetTagged("PlayerEntity")
            })
        end
    end)
end)

AbyssWorldLib:Init()