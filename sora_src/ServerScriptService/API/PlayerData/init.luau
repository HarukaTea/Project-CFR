local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Packages = ReplicatedStorage.Packages
local ReplicatedEnums = ReplicatedStorage.Constants.Enums
local ReplicatedTypings = ReplicatedStorage.Constants.Typing
local ServerTypings = ServerStorage.Constants.Typing
local ServerEnums = ServerStorage.Constants.Enums

local PlayerDataTyping = require(ReplicatedTypings.PlayerData)
local DataStoreTyping = require(ServerTypings.DataStore)

local PlayerDataTemplate = require(ServerStorage.Constants.Templates.PlayerData)

local DataStoreEnums = require(ServerEnums.DataStore)
local SaveSlotsEnum = require(ReplicatedEnums.SaveSlots)

local PlayerDataNetwork = require(ReplicatedStorage.Network.PlayerData)
local Places = require(ReplicatedEnums.Places)

local DataAccessorTyping = require(ServerTypings.DataAccessor)

local Lyra = require(Packages.lyra)
local Signal = require(ReplicatedStorage.Utils.Signal)
local Promise = require(ReplicatedStorage.Utils.Promise)
local TableUtil = require(Packages.TableUtil)

type TransformSaveslotFunc = (data: PlayerDataTyping.SaveSlot) -> boolean
type PlayerData = PlayerDataTyping.PlayerData
type SaveSlot = PlayerDataTyping.SaveSlot
type ModernDataStoreNames = DataStoreTyping.ModernDataStoreNames

type PromiseData = DataAccessorTyping.PromiseData

local api = {}
--- Caching player data so `store:get()` doesn't get used too much.
local profiles = {} :: {[Player]: PlayerData}
local dataAccessor = {} :: DataAccessorTyping.API

--- Returns the datastore based on the placeId.
function api.getDataStoreName(): ModernDataStoreNames
    local currentPlaceId = game.PlaceId
    return DataStoreEnums.modern[currentPlaceId]
        or DataStoreEnums.modern[Places.devPlace]
end

local store = Lyra.createPlayerStore({
    name = api.getDataStoreName(),
    template = PlayerDataTemplate.playerData,
    schema = PlayerDataTyping.schema,
})

local function getSaveSlots(allSaveSlots: {SaveSlot}, isArchived: boolean): {SaveSlot}
    local saveSlots = {}

    for _, saveSlot: SaveSlot in allSaveSlots do
        if saveSlot["isArchived"] == isArchived then
            table.insert(saveSlots, saveSlot)
        end
    end

    return saveSlots
end

local function cachePlayerData(player: Player, newData: PlayerData)
    profiles[player] = newData
end

-- API

--- Loads player's data, making it accessible via `api.get(player)`.
function api.loadData(player: Player): PromiseData
    return store:load(player)
    
    :andThen(function()
        local data = store:getAsync(player)

        if data then
            cachePlayerData(player, data)
        end

        return true
    end)
end

--- Unloads player's data, making it inaccessible unless loaded via `api.loadData(player)`.
function api.unloadData(player: Player)
    return store:unload(player)
    
    :andThen(function()
        profiles[player] = nil
    end)
end

--- Checks if the player's data is active in the server.
--- This is recommended to check if there is an active data before retrieving it.
function api.hasActiveData(player: Player): boolean
    if profiles[player] then
        return true
    end

    local ok, result = pcall(store.getAsync, store, player)

    if ok and result ~= nil then
        cachePlayerData(player, result)
        return true
    end

    return false
end

--- Checks if the player has an active slot index.
--- Sugar for `api.getSaveSlot(player, index) ~= nil`.
function api.hasActiveSlot(player: Player, index: number?): boolean
    return api.getSaveSlot(player, index) ~= nil
end

--- Retrieves player's data.
--- The player's data needs to be loaded first via `api.loadData(player)`
function api.getWholeData(player: Player): PlayerData
    local profileData = profiles[player]

    if profileData then
        return profileData
    end

    local retrievedData = store:getAsync(player)

    if retrievedData then
        cachePlayerData(player, retrievedData)
    end

    return retrievedData
end

--- Resets the player data based on the latest version.
function api.resetData(player: Player): PromiseData
    return store:updateImmutable(player, function(_data: PlayerData): PlayerData | false
        return TableUtil.Copy(PlayerDataTemplate.playerData, true)
    end)

    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false
        end

        local newData = store:getAsync(player)
        cachePlayerData(player, newData)

        PlayerDataNetwork.dataReset:send(nil, player)
        dataAccessor.playerSignals.dataReset:Fire(player)
        return true
    end)
end

--- Reconciles player data by filling missing data.
--- Does not work with legacy data.
function api.reconcileData(player: Player): PromiseData
    return store:update(player, function(data: PlayerData): boolean
        TableUtil.Sync(data, PlayerDataTemplate.playerData)
        return true
    end)

    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false
        end

        local newData = store:getAsync(player)
        cachePlayerData(player, newData)
        return true
    end)
end


--- Upgrades the player data's version to the latest, going step-by-step on each version.
--- **UNDER CONSTRUCTION**.
function api.upgradeData(player: Player)
    
end

--- Returns a table of active save slots.
function api.getActiveSaveSlots(player: Player)
    local playerData = api.getWholeData(player)
    return getSaveSlots(playerData.saveSlots, false)
end

--- Returns a table of archived save slots.
function api.getArchivedSaveSlots(player: Player)
    local playerData = api.getWholeData(player)
    return getSaveSlots(playerData.saveSlots, true)
end

--- Returns the index's save slot, or the currently selected save slot if no index is provided.
function api.getSaveSlot(player: Player, index: number?): SaveSlot?
    local playerData = api.getWholeData(player)
    local resolvedIndex = index or playerData.selectedSaveSlot
    local count: number = 1

    for _, saveSlot: SaveSlot in playerData.saveSlots do
        if saveSlot.isArchived then
            continue
        end

        if count == resolvedIndex then
            return saveSlot
        end

        count += 1
    end
end

--- Sets the current selected save slot index.
function api.setSelectedSaveSlot(player: Player, index: number): PromiseData
    local errorMessage: string?

    return store:update(player, function(playerData: PlayerData)
        if index < 1 or index > PlayerDataTemplate.maxSaveSlots then
            errorMessage = `The save slot selection index must be between 1 and {PlayerDataTemplate.maxSaveSlots}. Index: {index}`
            return false
        end

        playerData.selectedSaveSlot = index
        return true
    end)

    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false, errorMessage
        end

        local newData = store:getAsync(player)
        cachePlayerData(player, newData)

        dataAccessor.playerSignals.saveSlotSelected:Fire(player, newData.selectedSaveSlot)
        PlayerDataNetwork.saveSlotSelected:send(newData.selectedSaveSlot, player)
        return true
    end)
end

function api.createNewSlot(player: Player): PromiseData
    local errorMessage: string?

    return store:update(player, function(data: PlayerData): boolean
        local activeSaveSlots = getSaveSlots(data.saveSlots, false)

        if #activeSaveSlots >= SaveSlotsEnum.maxSaveSlots then
            errorMessage = `Maximum save slot count of {SaveSlotsEnum.maxSaveSlots} has been reached.`
            return false
        end

        local newSaveSlot = TableUtil.Copy(PlayerDataTemplate.saveSlot, true)
        table.insert(data.saveSlots, newSaveSlot)
        return true
    end)

    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false, errorMessage
        end

        local newData = store:getAsync(player)
        cachePlayerData(player, newData)
        return true
    end)
end

--- Sugar for `store:update()`. Usually handled by other APIs.
--- Returns a promise after the confirmation of the change.
function api.updateData(player: Player, transformFunction: (currentData: PlayerData) -> boolean): PromiseData
    return store:update(player, transformFunction)

    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false
        end

        local newData = store:getAsync(player)
        cachePlayerData(player, newData)
        return true
    end)
end

--- Updates a save slot by index, or the currently selected save slot if no index is provided.
function api.updateSaveSlot(player: Player, transformFunc: TransformSaveslotFunc, index: number?)
    return store:update(player, function(data: PlayerDataTyping.PlayerData): boolean
        local activeSaveSlots = getSaveSlots(data.saveSlots, false)
        local resolvedIndex = index or data.selectedSaveSlot
        local targetSlot = activeSaveSlots[resolvedIndex]

        if not targetSlot then
            return false
        end

        return transformFunc(targetSlot)
    end)

    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false
        end

        local newData = store:getAsync(player)
        cachePlayerData(player, newData)
        return true
    end)
end

function api.getSelectedSaveSlotIndex(player: Player): number
    return api.getWholeData(player).selectedSaveSlot
end

--[[ Initialisation ]]

dataAccessor.get = api.getWholeData
dataAccessor.hasActiveSlot = api.hasActiveSlot
dataAccessor.update = api.updateData
dataAccessor.getSaveSlot = api.getSaveSlot
dataAccessor.updateSaveSlot = api.updateSaveSlot
dataAccessor.getSelectedSaveSlotIndex = api.getSelectedSaveSlotIndex
dataAccessor.playerSignals = {
    dataReset = Signal(),
    saveSlotSelected = Signal(),
}

Promise.each(script:GetChildren(), function(module: ModuleScript, index: number)
    return Promise.new(function(resolve, reject, onCancel)
        local moduleData = require(module)

        moduleData.init(dataAccessor)
        resolve()
    end)
end)

:catch(warn)

return table.freeze(api)
