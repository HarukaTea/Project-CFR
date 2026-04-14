
repeat task.wait() until workspace:GetAttribute("Haruka_CompletedPreload")

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local worldConfig = ReplicatedStorage:FindFirstChild("WorldConfig", true) :: Configuration
if not worldConfig then return end

local cullingConfig = worldConfig:GetAttribute("CanCulling") :: boolean
if not cullingConfig then return end

local flowerContainer = workspace:WaitForChild("MapComponents", 999):WaitForChild("FlowerContainer", 999)
local treeContainer = workspace.MapComponents:WaitForChild("TreeContainer", 999)
local npcContainer = workspace.MapComponents:WaitForChild("NPCs", 999)
local nonNPCContainer = workspace.MapComponents:WaitForChild("Non-NPCs", 999)
local mapModelContainer = workspace:WaitForChild("Maps", 999):WaitForChild("MapModelContainer", 999)

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
})
    for _, entity: Model in CollectionService:GetTagged(data.Tag) do
        entity.Parent = data.Container
    end
end

_cull({
    Tag = "FlowerEntity",
    Container = flowerContainer,
    CullContainer = flowerCullContainer,
})
_cull({
    Tag = "NPCEntity",
    Container = npcContainer,
    CullContainer = npcCullContainer,
})
_cull({
    Tag = "NonNPCEntity",
    Container = nonNPCContainer,
    CullContainer = nonNPCCullContainer,
})
_cull({
    Tag = "TreeEntity",
    Container = treeContainer,
    CullContainer = treeCullContainer,
})
_cull({
    Tag = "MapModelPartEntity",
    Container = mapModelContainer,
    CullContainer = mapModelCullContainer,
})
