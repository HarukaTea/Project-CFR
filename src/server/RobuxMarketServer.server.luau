local ServerScriptService = game:GetService("ServerScriptService")


repeat task.wait() until workspace:GetAttribute("Haruka_ServerPlayerLibInited")


require(ServerScriptService.HarukaServer.Services.RobuxMarketLib)