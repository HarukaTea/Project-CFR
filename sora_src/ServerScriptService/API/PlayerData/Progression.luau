local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Promise = require(ReplicatedStorage.Utils.Promise)
local DataAccessor = require(ServerStorage.Constants.Typing.DataAccessor)

local LevelFormula = require(ReplicatedStorage.Shared.Formulas.Level)
local LevelEnums = require(ReplicatedStorage.Constants.Enums.PlayerLevel)

local levelCalculator = LevelFormula.new({
    baseExp = LevelEnums.baseExp,
    expPerLevel = LevelEnums.expPerLevel,
    multiPerLevel = LevelEnums.multiPerLevel,
    compoundingFactor = LevelEnums.compoundingFactor,
})

local dataAccessor = {} :: DataAccessor.API
local inited: boolean = false
local api = {}

function api.init(accessor: DataAccessor.API)
    if inited then
        return
    end

    dataAccessor = accessor
    inited = true
end

function api.getExp(player: Player, index: number?): number?
    local data = dataAccessor.getSaveSlot(player, index)

    if not data then
        
    end
end

--- Adds the amount to the save slot's current exp.
function api.addExp(player: Player, amount: number, index: number?)
    local _, currentExp = api.getExp(player, index)
    return api.setExp(player, currentExp + amount, index)
end

function api.setExp(player: Player, amount: number, index: number?)
    return dataAccessor.updateSaveSlot(player, function(data): boolean
        data.expPoints = amount
        return true
    end, index)
end

function api.setToLevel(player: Player, level: number, index: number?)
    local errorMessage: string?

    return dataAccessor.updateSaveSlot(player, function(data): boolean
        if not dataAccessor.hasActiveSlot(player, index) then
            return false
        end

        data.expPoints = levelCalculator:levelToExp(level)
        return true
    end, index)

    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false, errorMessage
        end

        return true
    end)
end

function api.getLevel(player: Player, index: number?): number
    if not dataAccessor.hasActiveSlot(player, index) then
        return 0
    end

    local _, expPoints = api.getExp(player, index)
    return levelCalculator:expToLevel(expPoints)
end

return table.freeze(api)