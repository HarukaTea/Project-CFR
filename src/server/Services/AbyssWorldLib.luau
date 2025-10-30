
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
    AbyssId: number
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


local wait = task.wait


function AbyssWorldLib:Init()
    for _, func: () -> nil in AbyssWorldLib.Funcs do
        Promise.try(func):catch(function(err)
            warn(tostring(err))
        end):await()
    end
    for _, func: () -> nil in AbyssWorldLib.ListenFuncs do
        task.spawn(func)
    end
end


--// Private functions


table.insert(AbyssWorldLib.Funcs, function()
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


    AbyssWorldLib.AbyssId = abyssId


    local folder = workspace.Enemies:FindFirstChild("_ABYSS_TEAM") :: Folder
    if not folder then
        warn("Did you forget to add the _ABYSS_TEAM folder to the Enemies folder?")
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

        locator:SetAttribute("_RESPAWN_SYMBOL", true)

        index += 1
    end

    RunService.Stepped:Wait()
    for _, locator: BasePart in totalMobs do
        if locator.Name == "GreenSlime" then
            locator:Destroy()
        end
    end

    workspace:SetAttribute("DungeonStarted", false)
end)





table.insert(AbyssWorldLib.ListenFuncs, function()
    Events.DUNGEON_RequestToStartDungeon.SetCallback(function()
        if AbyssWorldLib.Started then return end

        workspace:SetAttribute("DungeonStarted", true)
        AbyssWorldLib.Started = true

        Events.CreateCenterNotify.FireList(CollectionService:GetTagged("PlayerEntity"), "CHALLENGE STARTED!", true)
        Events.DUNGEON_StartDungeon.FireList(CollectionService:GetTagged("PlayerEntity"))

        workspace.MapComponents._AbyssAirwall:Destroy()


        local clockDisconnect = nil
        workspace:SetAttribute("DungeonLeftTime", 0)

        clockDisconnect = HarukaLib.Clock(1, function()
            if workspace:GetAttribute("DungeonFinished") then return end

            HarukaLib:AddAttr(workspace, "DungeonLeftTime", 1)
        end)

        repeat wait() until workspace:GetAttribute("DungeonFinished")

        if clockDisconnect then clockDisconnect() end
    end)
end)




table.insert(AbyssWorldLib.ListenFuncs, function()
    local folder = workspace.Enemies:FindFirstChild("_ABYSS_TEAM") :: Folder
    if not folder then
        warn("Did you forget to add the _ABYSS_TEAM folder to the Enemies folder?")
        return
    end

    repeat wait(1) until #folder:GetChildren() <= 0
    Events.DUNGEON_EndDungeon.FireList(CollectionService:GetTagged("PlayerEntity"))


    workspace:SetAttribute("DungeonFinished", true)


    wait(1)
    for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
        Promise.try(function()
            local char = player.Character
            local luck = 1
            if ServerLib.IsCharValid(char) then
                luck = char:GetAttribute("Luck") / 100 or 1
            end
            luck = math.max(1, luck)

            for _ = 1, 3 do
                Events.PlaySound.Fire(player, SoundService.SFXs.LootDropped)

                local result = HarukaLib:RollLoot(ItemBook:GetAllMaterialsLoot(), luck)

                ServerLib.GiveItemDrop(player, result, AbyssWorldLib.AbyssId * 10)
                wait(0.15)
            end
        end)
    end
end)




table.insert(AbyssWorldLib.ListenFuncs, function()
    Events.DUNGEON_RequestToLeaveDungeon.SetCallback(function(plr: Player)
        Events.CreateFSNotify.Fire(plr, "Teleporting back to Mainworld...", 999)

        local teleportOptions = Instance.new("TeleportOptions")

        local slotInfo = {
            [plr.Name] = plr:GetAttribute("SlotChosen")
        }
        teleportOptions:SetTeleportData({
            FromAbyss = true,
            SlotIds = slotInfo
        })

        wait(1)
        TeleportService:TeleportAsync(AssetBook.PlaceIds[tostring(game.GameId)].Mainworld, { plr }, teleportOptions)
    end)

    Events.DUNGEON_RequestToRestartDungeon.SetCallback(function(plr: Player)
        ServerBindables.RToChallengeAbyss:Fire(plr, {
            AbyssId = AbyssWorldLib.AbyssId
        })
    end)
end)

return AbyssWorldLib