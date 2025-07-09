local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Bindables = require(ReplicatedStorage.HarukaShared.Library.Bindables)
local Octree = require(ReplicatedStorage.HarukaShared.Shared.RbxUtility.Octree)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


local treeContainer = workspace:WaitForChild("TreeContainer", 999)
local flowerContainer = workspace:WaitForChild("FlowerContainer", 999)

local wait = task.wait



local treeAFKContainer = Instance.new("Folder")
treeAFKContainer.Name = "TreeAFKContainer"
treeAFKContainer.Parent = game:GetService("ServerStorage")

local flowerAFKContainer = Instance.new("Folder")
flowerAFKContainer.Name = "FlowerAFKContainer"
flowerAFKContainer.Parent = game:GetService("ServerStorage")


local treeOctree = Octree.new()
local flowerOctree = Octree.new()


local function _initTree(tree: Model)
    treeOctree:CreateNode(tree.WorldPivot.Position, tree)
end
local function _initFlower(flower: Model)
    flowerOctree:CreateNode(flower.WorldPivot.Position, flower)
end
for _, tree: Model in CollectionService:GetTagged("TreeEntity") do
    _initTree(tree)
end
CollectionService:GetInstanceAddedSignal("TreeEntity"):Connect(_initTree)

for _, flower: Model in CollectionService:GetTagged("FlowerEntity") do
    _initFlower(flower)
end
CollectionService:GetInstanceAddedSignal("FlowerEntity"):Connect(_initFlower)



Promise.try(function()
    local function _execute()
        local trees = treeOctree:RadiusSearch(workspace.CurrentCamera.CFrame.Position, 888)

        for _, tree: Model in treeContainer:GetChildren() do
            if not table.find(trees, tree) then
                tree.Parent = treeAFKContainer
            else
                table.remove(trees, table.find(trees, tree))
            end
        end
        for _, tree: Model in trees do
            tree.Parent = treeContainer
        end
    end
    Bindables.Titlescreen_CameraCFrameChanged:Once(_execute)


    HarukaLib.Clock(3, _execute)
end)
Promise.try(function()
    local function _execute()
        local flowers = flowerOctree:RadiusSearch(workspace.CurrentCamera.CFrame.Position, 555)

        for _, flower: Model in flowerContainer:GetChildren() do
            if not table.find(flowers, flower) then
                flower.Parent = flowerAFKContainer
            else
                table.remove(flowers, table.find(flowers, flower))
            end
        end
        for _, flower: Model in flowers do
            flower.Parent = flowerContainer
        end
    end
    Bindables.Titlescreen_CameraCFrameChanged:Once(_execute)


    HarukaLib.Clock(3, _execute)
end)