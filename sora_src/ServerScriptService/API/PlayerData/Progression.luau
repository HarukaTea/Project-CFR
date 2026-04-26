local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Promise = require(ReplicatedStorage.Utils.Promise)
local DataAccessor = require(ServerStorage.Constants.Typing.DataAccessor)

local ERR_SAVE_SLOT_NOT_FOUND = "Could not find player '%s' save slot to %s."

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

function api.getExp(player: Player, index: number?)
    local data = dataAccessor.getSaveSlot(player, index)

    return Promise.new(function(resolve, reject, onCancel)
        if not data then
            return reject(ERR_SAVE_SLOT_NOT_FOUND.format(player.Name, "get their data."))
        end
    end)
end

--- A
function api.addExp(player: Player, amount: number, index: number?)
    return dataAccessor.updateSaveSlot(player, function(data): boolean
        data.expPoints += amount
        return true
    end, index)
end

function api.setExp(player: Player, amount: number, index: number?)
    return dataAccessor.updateSaveSlot(player, function(data): boolean
        data.expPoints = amount
        return true
    end)
end

return table.freeze(api)