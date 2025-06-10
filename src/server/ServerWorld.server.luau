
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local SSS = game:GetService("ServerScriptService")

local Promise = require(RepS.HarukaShared.Shared.Promise)


local nowClock = os.clock()


do
    if RunService:IsClient() then
        warn("Invalid runtime environment")

        workspace:SetAttribute("Haruka_ServerLocked", true)


        for _, plr: Player in Players:GetPlayers() do
            plr:Kick("This server is invalid/locked. Rejoin can fix it.")
        end
        return
    end
end

--// Init server settings
do
	Players.CharacterAutoLoads = false
	StarterPlayer.CharacterUseJumpPower = true
    StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
    StarterPlayer.CameraMaxZoomDistance = 15.99 * 4.59

    Lighting.GlobalShadows = true
end


--// Init server modules
do
    require(SSS.HarukaServer.Services.ServerWorldLib):Init()
    require(SSS.HarukaServer.Shared.GlobalTimer)
    require(SSS.HarukaServer.Services.GlobalCriRPGLib):Init()
    require(SSS.HarukaServer.Services.GlobalQuestFuncLib):Init()
    require(RepS.HarukaShared.Shared.Maid):Init()
    require(SSS.HarukaServer.Shared.ProfileStore)
end


--// Init game debug
do
    local HarukaCMD = require(RepS.HarukaShared.Shared.HarukaCMD)
    local CommandBook = require(SSS.HarukaServer.Library.CommandBook)

    local harukaCMDObj = HarukaCMD.new()

    harukaCMDObj:Init()

    for _, command in CommandBook do
        harukaCMDObj:AddCommand(command)
    end
end


--// Init server location
do
    workspace:SetAttribute("ServerLocation", "Unknown")

    Promise.new(function()
        local serverInfo = HttpService:GetAsync("https://ipconfig.io/json", false)

        if serverInfo then
            local realInfo = HttpService:JSONDecode(serverInfo) :: table
            local serverLocation = realInfo["country_iso"] :: string

            if serverLocation then
                workspace:SetAttribute("ServerLocation", serverLocation)

                print("Server Location: "..serverLocation)
            end
        end

    end):catch(function()
        warn("Failed to fetch Server Location.")
    end)
end



print(`[ServerPreloadLib] HarukaServer Inited, Spent {string.format("%.2f", os.clock() - nowClock)} seconds`)
workspace:SetAttribute("Haruka_ServerInited", true)
