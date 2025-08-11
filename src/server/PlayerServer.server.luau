local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


local PlayerLib = require(ServerScriptService.HarukaServer.Services.PlayerLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)


local function initPlayer(player: Player)
    if #Players:GetPlayers() > Players.MaxPlayers then
        player:Kick("Server is full")
        return
    end
    if workspace:GetAttribute("Haruka_ServerLocked") then
        player:Kick("This server is invalid/locked. Rejoin can fix it.")
        return
    end
    if player.AccountAge < 2 then
        player:Kick("You must be at least 2 days old in Roblox Platform to play!")
        return
    end

    local playerObj = PlayerLib.new(player)
    if playerObj then
        playerObj:Init()
    end
end
for _, player: Player in Players:GetPlayers() do
    Promise.try(initPlayer, player)
end
Players.PlayerAdded:Connect(initPlayer)



workspace:SetAttribute("Haruka_ServerPlayerLibInited", true)