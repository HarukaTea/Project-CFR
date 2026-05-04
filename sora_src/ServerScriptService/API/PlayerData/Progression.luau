local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Promise = require(ReplicatedStorage.Utils.Promise)
local DataAccessor = require(ServerStorage.Constants.Typing.DataAccessor)

local LevelFormula = require(ReplicatedStorage.Shared.Formulas.Level)
local LevelEnums = require(ReplicatedStorage.Constants.Enums.PlayerLevel)

local ERR_SAVE_SLOT_NOT_FOUND = "Could not find player '%s' save slot to %s."

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

function api.getExp(player: Player, index: number?): Promise.TypedPromise<number>
    local data = dataAccessor.getSaveSlot(player, index)

    return Promise.new(function(resolve, reject, onCancel)
        if not data then
            return reject(ERR_SAVE_SLOT_NOT_FOUND.format(player.Name, "get their data."))
        end

        return resolve(data.expPoints)
    end)
end

--- Adds the amount to the save slot's current exp.
function api.addExp(player: Player, amount: number, index: number?)
    return api.setExp(player, api.getExp(player, index) + amount, index)
end

function api.setExp(player: Player, amount: number, index: number?)
    return dataAccessor.updateSaveSlot(player, function(data): boolean
        data.expPoints = amount
        return true
    end)
end

function api.setToLevel(player: Player, level: number, index: number?)
    
end

return table.freeze(api)