local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


local EntityLib = require(ServerScriptService.HarukaServer.Services.EntityLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)


local function initLocator(locator: BasePart)
    if not locator:IsA("BasePart") then return end
    if locator.Parent:IsA("BasePart") then return end

    locator.Transparency = 1


    local entityObj = EntityLib.new(locator)
    if entityObj then
        entityObj:Init()
    end
end
for _, locator: BasePart in CollectionService:GetTagged("EnemyLocatorEntity") do
    Promise.try(initLocator, locator)
end
CollectionService:GetInstanceAddedSignal("EnemyLocatorEntity"):Connect(initLocator)
