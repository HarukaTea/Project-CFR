local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Networks = ReplicatedStorage.Network
local ServerTyping = ServerStorage.Constants.Typing

local Cosmetics = require(ReplicatedStorage.Constants.Cosmetics)

local CosmeticNetwork = require(Networks.Cosmetics)

local DataAccessor = require(ServerTyping.DataAccessor)

local Promise = require(ReplicatedStorage.Utils.Promise)

local ERR_ID_DOES_NOT_EXIST: string = "There is no cosmetic id '%s'"
local ERR_ID_NOT_OWNED: string = "Player '%s' does not own '%s' to %s."
local ERR_ID_PROCESS_FAILED: string = "Player '%s' is unable to %s the cosmetic id '%s'."

type PromiseData = DataAccessor.PromiseData

local dataAccessor = {} :: DataAccessor.API
local inited: boolean = false
local api = {}

local function syncData(player: Player)
    local cosmeticData = dataAccessor.get(player).cosmetics
    local saveSlotData = dataAccessor.getSaveSlot(player)
    local equippedCosmetics = saveSlotData.selectedItems.cosmetic

    local dataToSend = {}

    for _, cosmeticId in cosmeticData do
        dataToSend[cosmeticId] = table.find(equippedCosmetics, cosmeticId) ~= nil
    end

    CosmeticNetwork.cosmeticItemsUpdated:send(dataToSend, player)
end

local function onSaveSlotSelected(player: Player, index: number)
    syncData(player)
end

local fun

-- INIT -- 

function api.init(accessor: DataAccessor.API)
    if inited then
        return
    end

    dataAccessor = accessor
    inited = true

    dataAccessor.playerSignals.saveSlotSelected:Connect(onSaveSlotSelected)
end

-- API

function api.hasCosmeticId(player: Player, cosmeticId: string): boolean
    return table.find(dataAccessor.get(player).cosmetics, cosmeticId) ~= nil
end

function api.isCosmeticIdEquipped(player: Player, cosmeticId: string, index: number?): boolean
    local saveSlot = dataAccessor.getSaveSlot(player, index)

    if not saveSlot then
        return false
    end

    return table.find(saveSlot.selectedItems.cosmetic, cosmeticId) ~= nil
end

function api.equipCosmetic(player: Player, cosmeticId: string, index: number?): PromiseData
    if not Cosmetics.hasCosmeticId(cosmeticId) then
        return Promise.resolve(false, ERR_ID_DOES_NOT_EXIST:format(cosmeticId))
    end

    if not api.hasCosmeticId(player, cosmeticId) then
        return Promise.resolve(false, ERR_ID_NOT_OWNED:format(player.Name, cosmeticId, "equip"))
    end

    return dataAccessor.updateSaveSlot(player, function(data)
        if table.find(data.selectedItems.cosmetic, cosmeticId) ~= nil then
            return false
        end

        table.insert(data.selectedItems.cosmetic, cosmeticId)
        return true
    end, index)

    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false, ERR_ID_PROCESS_FAILED:format(player.Name, "equip", cosmeticId)
        end

        return true
    end)
end

function api.unequipCosmetic(player: Player, cosmeticId: string, index: number?): PromiseData
    if not Cosmetics.hasCosmeticId(cosmeticId) then
        return Promise.resolve(false, ERR_ID_DOES_NOT_EXIST:format(cosmeticId))
    end

    if not api.hasCosmeticId(player, cosmeticId) then
        return Promise.resolve(false, ERR_ID_NOT_OWNED:format(player.Name, cosmeticId, "unequip"))
    end

    return dataAccessor.updateSaveSlot(player, function(data)
        local cosmeticItems = data.selectedItems.cosmetic
        local itemIndex = table.find(cosmeticItems, cosmeticId)

        if not itemIndex then
            return false
        end

        table.remove(cosmeticItems, itemIndex)
        return true
    end, index)

    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false, ERR_ID_PROCESS_FAILED:format(player.Name, "unequip", cosmeticId)
        end

        return true
    end)
end

function api.addCosmetic(player: Player, cosmeticId: string): PromiseData
    if not Cosmetics.hasCosmeticId(cosmeticId) then
        return Promise.resolve(false, ERR_ID_DOES_NOT_EXIST:format(cosmeticId))
    end

    return dataAccessor.update(player, function(data)
        if table.find(data.cosmetics, cosmeticId) then
            return false
        end

        table.insert(data.cosmetics, cosmeticId)
        return true
    end)

    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false, `Player '{player.Name}' already has a cosmetic id '{cosmeticId}'.`
        end

        return true
    end)
end

--- This shouldn't be used on normal occassions.
function api.removeCosmetic(player: Player, cosmeticId: string): PromiseData
    if not Cosmetics.hasCosmeticId(cosmeticId) then
        return Promise.resolve(false, ERR_ID_DOES_NOT_EXIST:format(cosmeticId))
    end

    if not api.hasCosmeticId(player, cosmeticId) then
        return Promise.resolve(false, `Player '{player.Name}' does not have a cosmetic id '{cosmeticId}' to remove.`)
    end

    return dataAccessor.update(player, function(data)
        local cosmeticItems = data.cosmetics
        local itemIndex = table.find(cosmeticItems, cosmeticId)

        if not itemIndex then
            return false
        end

        table.remove(cosmeticItems, itemIndex)
        return true
    end)

    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false, `Player '{player.Name}' does not have a cosmetic id '{cosmeticId}' to remove.`
        end

        return true
    end)
end

return table.freeze(api)