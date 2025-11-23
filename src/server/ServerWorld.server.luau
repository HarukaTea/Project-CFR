
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


do
    if RunService:IsClient() then
        warn("Invalid runtime environment")

        workspace:SetAttribute("Haruka_ServerLocked", true)


        for _, plr: Player in Players:GetPlayers() do
            plr:Kick("This server is shutting down, please do server hopping or wait for a while.")
        end
        return
    end
end

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
    require(SSS.HarukaServer.Shared.GlobalTimer)
    require(SSS.HarukaServer.Services.GlobalCriRPGLib):Init()
    require(SSS.HarukaServer.Services.GlobalQuestFuncLib):Init()

    require(RepS.HarukaShared.Shared.HarukaDebris)
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




--// add to live servers
do
    local worldIdWhiteList = { "InitusWorld" }
    local worldId = workspace:GetAttribute("WorldId") or "Unknown"

    if not table.find(worldIdWhiteList, worldId) then return end

    CADimension:Init()
    CADimension:AddToDimension()

    local serverSymbolContainer = workspace.MapComponents.GlobalServers :: Folder

    HarukaLib.Clock(15, function()
        local currentWorldServers = CADimension:GetWorlds()

        serverSymbolContainer:ClearAllChildren()

        for _, server: CADimension.ServerInfo in currentWorldServers do
            if not server.JobId then continue end
            if #server.PlayerUserIds <= 0 then continue end


            local symbol = Instance.new("IntValue")
            symbol.Name = server.JobId
            symbol.Value = #server.PlayerUserIds

            for _, userId in server.PlayerUserIds do
                local idSymbol = Instance.new("BoolValue")
                idSymbol.Name = userId
                idSymbol.Value = true
                idSymbol.Parent = symbol
            end

            symbol:SetAttribute("CityLocation", server.CityLocation)
            symbol:SetAttribute("ServerLocation", server.ServerLocation)
            symbol:SetAttribute("WorldId", server.WorldId)

            symbol.Parent = serverSymbolContainer
        end

    end, true)
end