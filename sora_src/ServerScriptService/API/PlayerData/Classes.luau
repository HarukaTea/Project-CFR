local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Promise = require(ReplicatedStorage.Utils.Promise)
local Table = require(ReplicatedStorage.Utils.Table)
local DataAccessor = require(ServerStorage.Constants.Typing.DataAccessor)
local PlayerDataTyping = require(ReplicatedStorage.Constants.Typing.PlayerData)
local PlayerDataTemplates = require(ServerStorage.Constants.Templates.PlayerData)

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

function api.getClassDetails(player: Player, className: string): PlayerDataTyping.ClassData
    local saveSlotData = dataAccessor.getSaveSlot(player)
    local classDetails = saveSlotData.classes[className]

    if not classDetails then
        dataAccessor.updateSaveSlot(player, function(data): boolean
            local newClassTable = Table.deepCopy(PlayerDataTemplates.classData)
            data.classes[className] = newClassTable
            return true
        end)
    end
end

function api.addExp(player: Player, amount: number)
    return dataAccessor.updateSaveSlot(player, function(data): boolean
       
    end)
end

function api.setExp(player: Player, amount: number)
    
end


return table.freeze(api)