
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// For teamwork purposes, init files that arent in the rojo Project

local plr = Players.LocalPlayer

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

if localTeamworkPackages:FindFirstChild("QuestBook") then
    local QuestBook = require(localTeamworkPackages.QuestBook)
    local RojoQuestBook = require(ReplicatedStorage.HarukaShared.Library.QuestBook)

    for questId: string, quest: RojoQuestBook.QuestJSON in QuestBook do
        RojoQuestBook[questId] = quest
    end
end

repeat task.wait() until plr.Character
repeat task.wait() until plr.Character.PrimaryPart
repeat task.wait() until plr.Character:GetAttribute("Haruka_CriRPGClientInited")

if localTeamworkPackages:FindFirstChild("MapLocal") then
    localTeamworkPackages.MapLocal:Clone().Parent = Players.LocalPlayer.PlayerScripts
end