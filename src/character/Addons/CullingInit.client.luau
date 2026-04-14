
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local worldConfig = ReplicatedStorage:FindFirstChild("WorldConfig", true) :: Configuration
if not worldConfig then return end

local cullingConfig = worldConfig:GetAttribute("CanCulling") :: boolean
if not cullingConfig then return end

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local ClientLib = require(ReplicatedStorage.HarukaShared.Controllers.ClientLib)
local Events = require(ReplicatedStorage.HarukaShared.Library.Events)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")
local plr = Players.LocalPlayer

repeat task.wait() until char:GetAttribute("Haruka_CriRPGClientInited")

ClientLib:TrackCharDiedEvent({
    Add = Add,
    Empty = Empty,
    Char = char,
    Player = plr
})

local flowerContainer = workspace:WaitForChild("MapComponents", 999):WaitForChild("FlowerContainer", 999)
local treeContainer = workspace.MapComponents:WaitForChild("TreeContainer", 999)
local npcContainer = workspace.MapComponents:WaitForChild("NPCs", 999)
local nonNPCContainer = workspace.MapComponents:WaitForChild("Non-NPCs", 999)
local mapModelContainer = workspace:WaitForChild("Maps", 999):WaitForChild("MapModelContainer", 999)

local plr = Players.LocalPlayer

local flowerRenderDistance = 188
local treeRenderDistance = 450
local mapModelRenderDistance = 525
local npcRenderDistance = 188

local function _createFolder(name: string) : Folder
    if SS:FindFirstChild(name) then
        return SS[name]
    end

    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = SS

    return folder
end

local flowerCullContainer = _createFolder("FlowerCullContainer")
local treeCullContainer = _createFolder("TreeCullContainer")
local npcCullContainer = _createFolder("NPCCullContainer")
local nonNPCCullContainer = _createFolder("NonNPCCullContainer")
local mapModelCullContainer = _createFolder("MapModelCullContainer")

local function _cull(data: {
    Tag: string,
    Container: Folder,
    CullContainer: Folder,
    RenderDistance: number,
})
    for _, entity: Model in CollectionService:GetTagged(data.Tag) do
        local distance = plr:DistanceFromCharacter(entity.WorldPivot.Position)

        if distance > data.RenderDistance and distance > 0 then
            if entity.Parent ~= data.CullContainer then
                entity.Parent = data.CullContainer
            end
        elseif distance <= data.RenderDistance and distance > 0 then
            if entity.Parent ~= data.Container then
                entity.Parent = data.Container
            end
        end
    end
end

Add(HarukaLib.Clock(1.5, function()
    _cull({
        Tag = "FlowerEntity",
        Container = flowerContainer,
        CullContainer = flowerCullContainer,
        RenderDistance = flowerRenderDistance,
    })
    _cull({
        Tag = "NPCEntity",
        Container = npcContainer,
        CullContainer = npcCullContainer,
        RenderDistance = npcRenderDistance,
    })
    _cull({
        Tag = "NonNPCEntity",
        Container = nonNPCContainer,
        CullContainer = nonNPCCullContainer,
        RenderDistance = npcRenderDistance,
    })
end, true))
Add(HarukaLib.Clock(3, function()
    _cull({
        Tag = "TreeEntity",
        Container = treeContainer,
        CullContainer = treeCullContainer,
        RenderDistance = treeRenderDistance,
    })
end, true))
Add(HarukaLib.Clock(4.5, function()
    _cull({
        Tag = "MapModelPartEntity",
        Container = mapModelContainer,
        CullContainer = mapModelCullContainer,
        RenderDistance = mapModelRenderDistance,
    })
end, true))

Add(Events.RefreshCullingAsync_S.On(function()
    _cull({
        Tag = "MapModelPartEntity",
        Container = mapModelContainer,
        CullContainer = mapModelCullContainer,
        RenderDistance = mapModelRenderDistance,
    })
    _cull({
        Tag = "TreeEntity",
        Container = treeContainer,
        CullContainer = treeCullContainer,
        RenderDistance = treeRenderDistance,
    })
end))
