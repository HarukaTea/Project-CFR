local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Network = ReplicatedStorage.Network
local Enums = ReplicatedStorage.Constants.Enums
local Typing = ReplicatedStorage.Constants.Typing
local SharedAPI = ReplicatedStorage.Shared.API

local Promise = require(ReplicatedStorage.Utils.Promise)

local DataAccessor = require(ServerStorage.Constants.Typing.DataAccessor)
local StatPointsTyping = require(Typing.PlayerData.StatPoints)

local LevelFormula = require(ReplicatedStorage.Shared.Formulas.Level)

local LevelEnums = require(Enums.PlayerLevel)

local SharedProgressionAPI = require(SharedAPI.PlayerData.Progression)

local ProgressionNetwork = require(Network.Progression)

local levelCalculator = LevelFormula.new({
    baseExp = LevelEnums.baseExp,
    expPerLevel = LevelEnums.expPerLevel,
    multiPerLevel = LevelEnums.multiPerLevel,
    compoundingFactor = LevelEnums.compoundingFactor,
})

local ERR_SAVE_SLOT_NOT_FOUND: string = "Player '%s' does not have save slot #%s."

type PromiseData = DataAccessor.PromiseData
type StatsData = StatPointsTyping.StatsData

local dataAccessor = {} :: DataAccessor.API
local inited: boolean = false
local api = {}

local function syncData(player: Player)
    
end

local function onSaveSlotSelected(player: Player, index: number)
    syncData(player)
end

-- INIT --

function api.init(accessor: DataAccessor.API)
    if inited then
        return
    end

    dataAccessor = accessor
    inited = true
end

-- API --

function api.getExp(player: Player, index: number?): number?
    local data = dataAccessor.getSaveSlot(player, index)
    return data.expPoints or -1
end

--- Adds the amount to the save slot's current exp.
function api.addExp(player: Player, amount: number, index: number?): PromiseData
    local _, currentExp = api.getExp(player, index)
    return api.setExp(player, currentExp + amount, index)
end

function api.setExp(player: Player, amount: number, index: number?): PromiseData
    if not dataAccessor.hasActiveSlot(player, index) then
        return Promise.resolve(false, ERR_SAVE_SLOT_NOT_FOUND:format(player.Name, index))
    end

    local oldExp = dataAccessor.getSaveSlot(player, index).expPoints

    return dataAccessor.updateSaveSlot(player, function(data): boolean
        data.expPoints = amount
        return true
    end, index)

    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false
        end

        ProgressionNetwork.playerExpUpdated:send({
            index = index,
            oldExp = oldExp,
            newExp = dataAccessor.getSaveSlot(player, index).expPoints,
        }, player)
        return true
    end)
end

function api.setToLevel(player: Player, level: number, index: number?): PromiseData
    if not dataAccessor.hasActiveSlot(player, index) then
        return Promise.resolve(false, ERR_SAVE_SLOT_NOT_FOUND:format(player.Name, index))
    end

    return api.setExp(
        player,
        levelCalculator:levelToExp(level),
        index
    )
end

function api.getLevel(player: Player, index: number?): number
    if not dataAccessor.hasActiveSlot(player, index) then
        return 0
    end

    local expPoints = api.getExp(player, index)
    return levelCalculator:expToLevel(expPoints)
end

function api.getTotalStatPoints(player: Player, index: number?): number
    if not dataAccessor.hasActiveSlot(player, index) then
        return -1
    end

    local saveSlotData = dataAccessor.getSaveSlot(player, index)
    return SharedProgressionAPI.getTotalStatPoints(
        saveSlotData.expPoints
    )
end

function api.getRemainingStatPoints(player: Player, index: number?): number
    if not dataAccessor.hasActiveSlot(player, index) then
        return -1
    end

    local saveSlotData = dataAccessor.getSaveSlot(player, index)
    return SharedProgressionAPI.getRemainingStatPoints(
        saveSlotData.expPoints,
        saveSlotData.statPoints
    )
end

function api.setStatPoints(player: Player, newStats: StatsData, index: number?): PromiseData
    if not dataAccessor.hasActiveSlot(player, index) then
        return Promise.resolve(false, `Player '{player.Name}' does not have save slot #{index} to allocate stats.`)
    end

    if not StatPointsTyping.statPointsT(newStats) then
        return Promise.resolve(false, `Player '{player.Name}'s stats cannot be allocated with new stats as it is invalid.`)
    end

    local errorMessage: string?

    return dataAccessor.updateSaveSlot(player, function(data)
        if not SharedProgressionAPI.canAllocateStatPoints(data.statPoints, newStats) then
            errorMessage = `Player '{player.Name}' does not have enough stat points to set new allocated stat points.`
            return false
        end

        data.statPoints = newStats
        return true
    end, index)

    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false, errorMessage
        end

        return true
    end)
end

return table.freeze(api)