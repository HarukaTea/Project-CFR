
repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


local CollectionService = game:GetService("CollectionService")
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

    Init: (self: AbyssWorldLibClass) -> nil,
    GiveLoot: () -> nil
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

local AbyssTeambook = require(ReplicatedStorage.HarukaShared.Library.AbyssTeambook)
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




local wait = task.wait


function AbyssWorldLib:Init()
    Promise.try(AbyssWorldLib.Funcs[1]):await()

    for _, func: () -> nil in AbyssWorldLib.ListenFuncs do
        task.spawn(func)
    end
end


--// Private functions


function AbyssWorldLib.GiveLoot()
    for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
        Promise.try(function()
            local char = player.Character
            local luck = 1
            if ServerLib.IsCharValid(char) then
                luck = char:GetAttribute("Luck") / 100 or 1
            end
            luck = math.max(1, luck)

            for _ = 1, 3 do
                Events.PlaySound_S.Fire(player, SoundService.SFXs.LootDropped)

                local result = HarukaLib:RollLoot(ItemBook:GetAllMaterialsLoot(), luck)

                ServerLib.GiveItemDrop(player, result, AbyssWorldLib.AbyssId * 10)
                wait(0.15)
            end
        end)
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
    for mobId: string, mobInfo in AbyssTeambook[abyssId].Team do
        if not totalMobs[index] then break end

        local locator = totalMobs[index] :: BasePart

        locator.Name = mobId
        locator:SetAttribute("Level", mobInfo.Level)
        locator:SetAttribute("EnvironmentBonus", mobInfo.EnvironmentBonus)

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
end)





table.insert(AbyssWorldLib.ListenFuncs, function()
    Events.Abyss_StartAbyss_C.SetCallback(function()
        if AbyssWorldLib.Started then return end
        AbyssWorldLib.Started = true

        Events.CreateCenterNotify_S.FireList(CollectionService:GetTagged("PlayerEntity"), "CHALLENGE STARTED!", true)

        workspace:SetAttribute("AbyssStarted", true)

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
    task.delay(1, AbyssWorldLib.GiveLoot)
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