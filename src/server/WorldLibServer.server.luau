
repeat task.wait() until workspace:GetAttribute("Haruka_ServerValidated")


local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local SSS = game:GetService("ServerScriptService")

local Promise = require(RepS.HarukaShared.Shared.Promise)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local CADimension = require(SSS.HarukaServer.Shared.CADimension)


type Dict = { [string]: {any} }

local nowClock = os.clock()


--// Init server settings
do
	Players.CharacterAutoLoads = false
	StarterPlayer.CharacterUseJumpPower = true
    StarterPlayer.EnableMouseLockOption = false
    StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
    StarterPlayer.CameraMaxZoomDistance = 159

    Lighting.GlobalShadows = true
end


--// Init server modules
do
    require(SSS.HarukaServer.Services.ServerWorldLib):Init()
    require(SSS.HarukaServer.Services.GlobalCriRPGLib):Init()
    require(SSS.HarukaServer.Services.GlobalQuestFuncLib):Init()

    require(SSS.HarukaServer.Shared.GlobalTimer)
    require(RepS.HarukaShared.Shared.HarukaDebris)
end


--// Init game debug
do
    local HarukaCMD = require(RepS.HarukaShared.Shared.HarukaCMD)

    local harukaCMDObj = HarukaCMD.new()
    harukaCMDObj:Init()
    harukaCMDObj:AddCommandBook(require(SSS.HarukaServer.Library.CommandBook))
end


--// Init server location
do
    workspace:SetAttribute("ServerLocation", "Unknown")
    workspace:SetAttribute("CityLocation", "Unknown")

    Promise.new(function()
        local serverInfo = HttpService:GetAsync("https://api.ipbase.com/v1/json/", false)

        if serverInfo then
            local realInfo = HttpService:JSONDecode(serverInfo) :: { any }
            local serverLocation = realInfo["country_code"] :: string
            local cityLocation = realInfo["city"] :: string

            if serverLocation then
                workspace:SetAttribute("ServerLocation", serverLocation)
                print("Server Location: "..serverLocation)
            end
            if cityLocation then
                workspace:SetAttribute("CityLocation", cityLocation)
                print("City Location: "..cityLocation)
            end
        end

    end):catch(function(err)
        warn("Failed to fetch Server Location.")

        if RunService:IsStudio() then
            warn(tostring(err))
        end
    end)
end



print(`[ServerPreloadLib] HarukaServer Inited, Spent {string.format("%.2f", os.clock() - nowClock)} seconds`)
workspace:SetAttribute("Haruka_ServerInited", true)



--// server runtime too long
do
    Promise.delay(60 * 60 * 6):andThen(function()
        warn("[Warn] Server has reached max runtime")

        workspace:SetAttribute("Haruka_ServerLocked", true)

        HarukaLib.Clock(5, function()
            for _, plr: Player in Players:GetPlayers() do
                plr:Kick("[Error] The server has been running for over 6 hours, please rejoin a new one!")
            end
        end)

        CADimension:RemoveFromDimension()
    end)
end
