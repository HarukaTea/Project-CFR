local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local GroupDetails = require(ReplicatedStorage.Constants.Enums.Group)
local DataAccessor = require(ServerStorage.Constants.Typing.DataAccessor)
local ModerationEnums = require(ServerStorage.Constants.Enums.Moderation)
local PlayerDataTyping = require(ReplicatedStorage.Constants.Typing.PlayerData)

local GROUP_ID: number = GroupDetails.groupId
local MODERATOR_RANKS: { number } = ModerationEnums.modRanks

type AutomatedLogData = PlayerDataTyping.AutomatedLogData
type PlayerData = PlayerDataTyping.PlayerData
type PlayerCacheData = {
    groupRank: number,
}
type BanType = "manual" | "auto"
type BanConfig = {
    UserIds: { number },
    --- True by default
    ApplyToUniverse: boolean?,
    Duration: number,
    DisplayReason: string,
    PrivateReason: string,
    --- False by default
    ExcludeAltAccounts: boolean?
}
type BanDetails = {
    banType: BanType,
    publicReason: string,
    privateReason: string
}

local _cache = {} :: { [Player]: PlayerCacheData }
local dataAccessor = {} :: DataAccessor.API
local inited: boolean = false
local api = {}

-- PRIVATE FUNCTIONS --

local function cachePlayer(player: Player)
    local newCache: PlayerCacheData = {}
    local playerRank: number = player:GetRankInGroupAsync(GROUP_ID)

    newCache.groupRank = playerRank
end

local function isPlayerCached(player: Player): boolean
    return _cache[player] ~= nil
end

local function validatePlayerCache(player: Player)
    if not isPlayerCached(player) then
        cachePlayer(player)
    end
end

local function getPlayerCache(player: Player)
    validatePlayerCache(player)
    return _cache[player]
end

local function isModerator(player: Player): boolean
    if isPlayerCached(player) then
        validatePlayerCache(player)
    end

    local playerRank: number = getPlayerCache(player)
    return table.find(MODERATOR_RANKS, playerRank) ~= nil
end

-- PUBLIC FUNCTIONS --

function api.init(accessor: DataAccessor.API)
    if inited then
        return
    end

    dataAccessor = accessor
    inited = true
end

--- Checks if the player is banned based on the latest mod log.
function api.isPlayerBanned(player: Player): boolean
    local playerData = dataAccessor.get(player)
    local modLogs = playerData.internal.modLogs
    local startDate = modLogs[1].dateStarted
    local duration = modLogs[1].duration
    return startDate + duration <= DateTime.now().UnixTimestamp
end

--- Task: decode private reason from player ban history
function api.getPlayerBanHistory(player: Player)
    
end

--- Bans the player for said `duration`.
--- `duration` is in seconds.
function api.banPlayer(player: Player, reason: string, duration: DateTime, moderator: Player): boolean
    validatePlayerCache(player)
    validatePlayerCache(moderator)

    if not isModerator(moderator) then
        return false
    end

    local metaData = HttpService:JSONEncode({
        
    })

    Players:BanAsync({
        UserIds = { player.UserId },
        DisplayReason = reason,
        PrivateReason = metaData,
        Duration = duration,
    } :: BanConfig)
end

--- Unbans the player.
--- If the player is not banned then this will return false.
function api.unbanPlayer(player: Player, reason: string, moderator: Player?): boolean
    if not api.isPlayerBanned(player) then
        return false
    end
    return true
end

function api.flagPlayer(severity: number, reason: string, duration: DateTime)
    
end

-- INITIALISATION --

-- Always assume that the player moderator is in the server.
-- If the moderator isn't the server, then clearly this isn't done properly, which causes lingering data.
local function onPlayerRemoving(player: Player)
    _cache[player] = nil
end

Players.PlayerRemoving:Connect(onPlayerRemoving)

return table.freeze(api)