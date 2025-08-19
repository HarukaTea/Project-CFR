local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Bindables = require(ReplicatedStorage.HarukaShared.Library.Bindables)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


local treeContainer = workspace:WaitForChild("TreeContainer", 999)
local flowerContainer = workspace:WaitForChild("FlowerContainer", 999)

local plr = Players.LocalPlayer

local wait = task.wait


local treeRenderDistance = 888
local flowerRenderDistance = 555

HarukaLib:Hydrate(workspace, {
    ["Attr-TreeRenderDistance"] = function(val: number)
        val = val or 888
        treeRenderDistance = val
    end,
    ["Attr-FlowerRenderDistance"] = function(val: number)
        val = val or 555
        flowerRenderDistance = val
    end
})



local treeAFKContainer = Instance.new("Folder")
treeAFKContainer.Name = "TreeAFKContainer"
treeAFKContainer.Parent = game:GetService("ServerStorage")

local flowerAFKContainer = Instance.new("Folder")
flowerAFKContainer.Name = "FlowerAFKContainer"
flowerAFKContainer.Parent = game:GetService("ServerStorage")


Promise.try(function()
    local function _execute()
        for _, tree: Model in CollectionService:GetTagged("TreeEntity") do
            local distance = plr:DistanceFromCharacter(tree.WorldPivot.Position)
            if distance > treeRenderDistance or distance <= 0 then
                tree.Parent = treeAFKContainer
            else
                tree.Parent = treeContainer
            end
        end
    end
    Bindables.Titlescreen_CameraCFrameChanged:Once(_execute)


    HarukaLib.Clock(3, _execute)
end)
Promise.try(function()
    local function _execute()
        for _, flower: Model in CollectionService:GetTagged("FlowerEntity") do
            local distance = plr:DistanceFromCharacter(flower.WorldPivot.Position)
            if distance > flowerRenderDistance or distance <= 0 then
                flower.Parent = flowerAFKContainer
            else
                flower.Parent = flowerContainer
            end
        end
    end
    Bindables.Titlescreen_CameraCFrameChanged:Once(_execute)


    HarukaLib.Clock(3, _execute)
end)