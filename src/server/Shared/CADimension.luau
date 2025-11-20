
--// https://devforum.roblox.com/t/liveserversservice-fetch-running-servers-with-simple-code/3915958
--// @Modifier: HarukaTea


local MSS = game:GetService("MemoryStoreService")
local HTTP = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


local liveWorldsHashMap = MSS:GetHashMap("CF_Dimension")
local key = "_AllWorlds"


local privateServerId = game.PrivateServerId
local serverId = game.JobId

local isUploaded = false
local isRemoving = false
local isInited = false


local MAX_TIME = 60 * 60 * 24


export type ServerInfo = {
    PlayerUserIds: { string },
    WorldId: string,
    JobId: string,
    ServerLocation: string,
    CityLocation: string
}


type Dict = { [string]: {any} }


local function _getTableSizeInKB(t: {any?}): number
	local encoded = HTTP:JSONEncode(t)
	local size = #encoded

	return size / 1000
end

local CADimensions = {}

function CADimensions:Init()
	if isInited then return end
    if RunService:IsStudio() then return end

	isInited = true

    HarukaLib.TryUntil(function()
        liveWorldsHashMap:UpdateAsync(key, function(oldValue: Dict)
            oldValue = oldValue or {}

            return oldValue
        end, MAX_TIME)
    end, 2)


	game:BindToClose(function()
		CADimensions:RemoveFromDimension()
	end)


    print("[CADimension] Connected to CF Dimension")
end


function CADimensions:AddToDimension()
	local refreshRate = 30

	if isUploaded then return end
    if privateServerId ~= "" then return end
    if RunService:IsStudio() then return end

	isUploaded = true


    self.thread = HarukaLib.Clock(refreshRate, function()
        HarukaLib.TryUntil(function()
            local playerIds = {}
            for _, player: Player in Players:GetPlayers() do
                table.insert(playerIds, tostring(player.UserId))
            end

            local serverLocation = workspace:GetAttribute("ServerLocation") or "Unknown"
            local cityLocation = workspace:GetAttribute("CityLocation") or "Unknown"
            local worldId = workspace:GetAttribute("WorldId") or "Unknown"

            local dataToUpload = {
                PlayerUserIds = playerIds,
                WorldId = worldId,
                JobId = game.JobId,
                ServerLocation = serverLocation,
                CityLocation = cityLocation
            } :: ServerInfo

            liveWorldsHashMap:UpdateAsync(key, function(oldValue: Dict)
                if _getTableSizeInKB(oldValue) >= 30 * 1024 then
                    return {}
                end
                oldValue = oldValue or {}

                oldValue[serverId] = dataToUpload

                return oldValue
            end, MAX_TIME)
        end, 2)
    end, true)


    print("[CADimension] Uploaded to CF Dimension")
end

function CADimensions:RemoveFromDimension()
	if isRemoving then return end
    if RunService:IsStudio() then return end

	isRemoving = true
    if self.thread then self.thread() end


    HarukaLib.TryUntil(function()
        liveWorldsHashMap:UpdateAsync(key, function(oldValue: Dict)
            oldValue = oldValue or {}
            oldValue[serverId] = nil

            return oldValue
        end, MAX_TIME)

    end, 2, function()
        isRemoving = false
        isUploaded = false
    end)
end


function CADimensions:GetWorlds(): {
    [string]: ServerInfo
}
	return liveWorldsHashMap:GetAsync(key) or {}
end


return CADimensions

