
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


local flowerContainer = workspace:WaitForChild("MapComponents", 999):WaitForChild("FlowerContainer", 999)

local plr = Players.LocalPlayer

local flowerRenderDistance = 188

local flowerAFKContainer = Instance.new("Folder")
flowerAFKContainer.Name = "FlowerAFKContainer"
flowerAFKContainer.Parent = game:GetService("ServerStorage")


HarukaLib.Clock(3, function()
    for _, flower: Model in CollectionService:GetTagged("FlowerEntity") do
        local distance = plr:DistanceFromCharacter(flower.WorldPivot.Position)
        if distance > flowerRenderDistance or distance <= 0 then
            flower.Parent = flowerAFKContainer
        else
            flower.Parent = flowerContainer
        end
    end
end)