
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")


local DungeonWorldLib = {}

local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)


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

    for _, locator: BasePart in CollectionService:GetTagged("EnemyLocatorEntity") do
        locator:SetAttribute("NoRespawn", true)
    end


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
end



function DungeonWorldLib:_ListenDungeonRequestsTracker()
    Events.DUNGEON_RequestToStartDungeon.SetCallback(function(plr: Player)
        --// FIXME: remove this line
        if plr.UserId ~= 304008764 then return end

        workspace:SetAttribute("DungeonStarted", true)

        Events.CreateCenterNotify.FireList(CollectionService:GetTagged("PlayerEntity"), "DUNGEON STARTED!", true)
        Events.CreateNotify.FireList(CollectionService:GetTagged("PlayerEntity"), `{plr.Name} Started the Dungeon!`)
        Events.DUNGEON_StartDungeon.FireList(CollectionService:GetTagged("PlayerEntity"))


        workspace.MapComponents:FindFirstChild("_DungeonStartAirWall", true):Destroy()
    end)
end



function DungeonWorldLib:_ListenDungeonStageAirwallDestroyTracker()
    HarukaLib.Clock(1, function()
        for _, part: BasePart in CollectionService:GetTagged("DungeonStageWallEntity") do
            if workspace:GetAttribute("_DUNGEON_"..part.Name.."_PASSED") then
                part:Destroy()
            end
        end
    end)
end


return DungeonWorldLib
