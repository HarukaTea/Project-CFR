
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
local placeIdStr = tostring(game.PlaceId)

local isUploaded = false
local isRemoving = false
local isInited = false



export type ServerInfo = {
    PlayerUserIds: {number},
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
            if not oldValue then
                return { [placeIdStr] = {} }
            end
            return oldValue
        end, 3888000)
    end, 2)


	game:BindToClose(function()
		CADimensions:RemoveFromLiveServers()
	end)

    print("[HarukaServer] Added to CF Dimension")
end


function CADimensions:AddToDimension(refreshRate: number?)
	refreshRate = refreshRate or 300

	if isUploaded then return end
    if privateServerId ~= "" then return end
    if RunService:IsStudio() then return end

	isUploaded = true


    HarukaLib.Clock(refreshRate, function()
        HarukaLib.TryUntil(function()
            local playerIds = {}
            for _, player: Player in Players:GetPlayers() do
                table.insert(playerIds, player.UserId)
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
                if _getTableSizeInKB(oldValue) >= 32 * 1024 then
                    return nil
                end
                oldValue = oldValue or {}

                if not oldValue[placeIdStr] then
                    oldValue[placeIdStr] = {}
                end

                oldValue[placeIdStr][serverId] = dataToUpload

                return oldValue
            end, 3888000)
        end, 2)
    end, true)
end

function CADimensions:RemoveFromDimension()
	if isRemoving then return end
    if RunService:IsStudio() then return end

	isRemoving = true


    HarukaLib.TryUntil(function()
        liveWorldsHashMap:UpdateAsync(key, function(oldValue: Dict)
            oldValue = oldValue or {}

            if not oldValue[placeIdStr] then
                oldValue[placeIdStr] = {}
            end

            oldValue[placeIdStr][serverId] = nil
            return oldValue
        end, 3888000)

    end, 2, function()
        isRemoving = false
        isUploaded = false
    end)
end


-- PlaceId defaults to game.PlaceId, whereas ExcludeSelf defaults to true
function CADimensions:GetWorlds(maxFetch: number?, excludeThisServer: boolean?, placeId: number?): {[string]: {
    [string]: ServerInfo
}}
	placeId = placeId or game.PlaceId
	excludeThisServer = (excludeThisServer == nil and true) or excludeThisServer
	maxFetch = maxFetch or 20

	local data = {}

    HarukaLib.TryUntil(function()
        liveWorldsHashMap:GetAsync(key)

    end, 2, function(result)
        if excludeThisServer then
            result = result or {}

            if not result[placeIdStr] then
                result[placeIdStr] = {}
            end

            result[placeIdStr][serverId] = nil
        end


        local dataTable = HarukaLib.TableUtils.Cut(result[placeIdStr], maxFetch)
        data = dataTable
    end)

	return data
end


return CADimensions

