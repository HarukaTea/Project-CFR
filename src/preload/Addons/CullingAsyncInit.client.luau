
repeat task.wait() until workspace:GetAttribute("Haruka_CompletedPreload")


local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")


local worldConfig = ReplicatedStorage:FindFirstChild("WorldConfig") :: Configuration
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

local flowerAFKContainer = _createFolder("FlowerAFKContainer")
local treeAFKContainer = _createFolder("TreeAFKContainer")
local npcAFKContainer = _createFolder("NPCAFKContainer")
local nonNPCAFKContainer = _createFolder("NonNPCAFKContainer")
local mapModelAFKContainer = _createFolder("MapModelAFKContainer")



local function _cullAFK(data: {
    Tag: string,
    Container: Folder,
    AFKContainer: Folder,
})
    for _, entity: Model in CollectionService:GetTagged(data.Tag) do
        entity.Parent = data.AFKContainer
    end
end


_cullAFK({
    Tag = "FlowerEntity",
    Container = flowerContainer,
    AFKContainer = flowerAFKContainer,
})
_cullAFK({
    Tag = "NPCEntity",
    Container = npcContainer,
    AFKContainer = npcAFKContainer,
})
_cullAFK({
    Tag = "NonNPCEntity",
    Container = nonNPCContainer,
    AFKContainer = nonNPCAFKContainer,
})
_cullAFK({
    Tag = "TreeEntity",
    Container = treeContainer,
    AFKContainer = treeAFKContainer,
})
_cullAFK({
    Tag = "MapModelPartEntity",
    Container = mapModelContainer,
    AFKContainer = mapModelAFKContainer,
})
