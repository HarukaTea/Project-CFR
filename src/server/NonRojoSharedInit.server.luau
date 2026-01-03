
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// For teamwork purposes, init files that arent in the rojo Project

repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


local localTeamworkPackages = ReplicatedStorage:FindFirstChild("_LocalRojoShared") :: Folder
if not localTeamworkPackages then return end


--// init LocationBook

if localTeamworkPackages:FindFirstChild("LocationBook") then
    local LocationBook = require(localTeamworkPackages.LocationBook)
    local RojoLocationBook = require(ReplicatedStorage.HarukaShared.Library.LocationBook)


    for id: string, location: RojoLocationBook.LocationInfo in LocationBook do
        RojoLocationBook[id] = location
    end
end

if localTeamworkPackages:FindFirstChild("MapServer") then
    localTeamworkPackages.MapServer:Clone().Parent = ServerScriptService
end

if localTeamworkPackages:FindFirstChild("QuestBook") then
    local QuestBook = require(localTeamworkPackages.QuestBook)
    local RojoQuestBook = require(ReplicatedStorage.HarukaShared.Library.QuestBook)


    for questId: string, quest: RojoQuestBook.QuestJSON in QuestBook do
        RojoQuestBook[questId] = quest
    end
end
