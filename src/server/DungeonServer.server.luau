local ServerScriptService = game:GetService("ServerScriptService")

repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


if not workspace:GetAttribute("DungeonId") then return end


local DungeonWorldLib = require(ServerScriptService.HarukaServer.Services.DungeonWorldLib)
if DungeonWorldLib then
    DungeonWorldLib:Init()
end