
--// https://devforum.roblox.com/t/liveserversservice-fetch-running-servers-with-simple-code/3915958
--// @Modifier: HarukaTea


local MSS = game:GetService("MemoryStoreService")
local HTTP = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


local liveServersHashMap = MSS:GetHashMap("CF_LiveServers")
local key = "_GlobalServers"


local privateServerId = game.PrivateServerId
local serverId = game.JobId
local placeIdStr = tostring(game.PlaceId)

local isUploaded = false
local isRemoving = false
local isInited = false


type Dict = { [string]: {any} }


local function _getTableSizeInKB(t: {any?}): number
	local encoded = HTTP:JSONEncode(t)
	local size = #encoded

	return size / 1000
end

local LSS = {}

function LSS:Initiate()
	if isInited then return end

	isInited = true

    HarukaLib.TryUntil(function()
        liveServersHashMap:UpdateAsync(key, function(oldValue: Dict)
            if not oldValue then
                return { [placeIdStr] = {} }
            end
            return oldValue
        end, 3888000)
    end, 2)


	game:BindToClose(function()
		LSS:RemoveFromLiveServers()
	end)

    print("[HarukaServer] Added to live servers")
end


function LSS:AddToLiveServers(refreshRate: number?)
	refreshRate = refreshRate or 300

	if isUploaded then return end
    if privateServerId ~= "" then return end

	isUploaded = true


    HarukaLib.Clock(refreshRate, function()
        HarukaLib.TryUntil(function()
            local dataToUpload = {
                PlayersCount = #Players:GetPlayers(),
                WorldId = workspace:GetAttribute("WorldId") or "Unknown",
                JobId = game.JobId,
                ServerLocation = workspace:GetAttribute("ServerLocation") or "Unknown"
            }

            liveServersHashMap:UpdateAsync(key, function(oldValue: Dict)
                if _getTableSizeInKB(oldValue) >= 32 * 1024 then
                    return nil
                end
                if not oldValue then
                    return nil
                end
                if not oldValue[placeIdStr] then
                    oldValue[placeIdStr] = {}
                end

                oldValue[placeIdStr][serverId] = dataToUpload

                return oldValue
            end, 3888000)
        end, 2)
    end, true)
end

function LSS:RemoveFromLiveServers()
	if isRemoving then return end
	isRemoving = true


    HarukaLib.TryUntil(function()
        liveServersHashMap:UpdateAsync(key, function(oldValue: Dict)
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
function LSS:GetLiveServers(maxFetch: number?, excludeThisServer: boolean?, placeId: number?): {[string]: Dict}
	placeId = placeId or game.PlaceId
	excludeThisServer = (excludeThisServer == nil and true) or excludeThisServer
	maxFetch = maxFetch or 20

	local data = {}

    HarukaLib.TryUntil(function()
        liveServersHashMap:GetAsync(key)

    end, 2, function(result)
        if excludeThisServer then
            if not result[placeIdStr] then
                result[placeIdStr] = {}
            end

            result[placeIdStr][serverId] = nil
        end


        local dataTable = HarukaLib.TableUtils.Cut(result[placeIdStr][serverId], maxFetch)
        data = dataTable
    end)

	return data
end


return LSS

