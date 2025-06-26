local ServerScriptService = game:GetService("ServerScriptService")

repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


if not workspace:GetAttribute("AbyssId") then return end


local AbyssWorldLib = require(ServerScriptService.HarukaServer.Services.AbyssWorldLib)

if AbyssWorldLib then
    AbyssWorldLib:Init()
end