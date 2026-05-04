local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Packages = ReplicatedStorage.Packages
local ReplicatedTypings = ReplicatedStorage.Constants.Typing
local ServerTypings = ServerStorage.Constants.Typing

local Template = require(ServerStorage.Constants.Templates.PlayerData)
local PlayerDataTyping = require(ReplicatedTypings.PlayerData)
local DataStoreTyping = require(ServerTypings.DataStore)
local DataStore = require(ServerStorage.Constants.Enums.DataStore)
-- will be used later when network is implemented.
-- Remind Sora to work on this.
local Network = require(ReplicatedStorage.Network.PlayerData)
local Places = require(ReplicatedStorage.Constants.Enums.Places)
local Version = require(ReplicatedStorage.Constants.Enums.Version)

local DataAccessorTyping = require(ServerTypings.DataAccessor)

local Migration = require(ServerStorage.Migration)
local Lyra = require(Packages.lyra)
local Promise = require(ReplicatedStorage.Utils.Promise)
local Table = require(ReplicatedStorage.Utils.Table)

local DebuggingNetwork = require(ReplicatedStorage.Network.Debugging)

type TransformSaveslotFunc = (data: PlayerDataTyping.SaveSlot) -> boolean
type PlayerData = PlayerDataTyping.PlayerData
type SaveSlot = PlayerDataTyping.SaveSlot
type ModernDataStoreNames = DataStoreTyping.ModernDataStoreNames

local api = {}
--- Caching player data so `store:get()` doesn't get used too much.
local profiles = {} :: {[Player]: PlayerData}
local dataAccessor = {} :: DataAccessorTyping.API

--- Returns the datastore based on the placeId.
function api.getDataStoreName(): ModernDataStoreNames
    local currentPlaceId = game.PlaceId
    return DataStore.modern[currentPlaceId]
        or DataStore.modern[Places.devPlace]
end

local store = Lyra.createPlayerStore({
    name = api.getDataStoreName(),
    template = Template.playerData,
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

local function broadcastError(header: string, errorMsg: string)
    DebuggingNetwork.logOccurred:send({
        level = "error",
        header = header,
        message = tostring(errorMsg),
        sender = script.Name,
    }, Players:GetPlayers())
end

-- API

--- Loads player's data, making it accessible via `api.get(player)`.
function api.loadData(player: Player)
    return store:load(player):catch(function(errorMsg)
        broadcastError("loadData", errorMsg)
    end)
end

--- Unloads player's data, making it inaccessible unless loaded via `api.loadData(player)`.
--- This will kick the player after the data is unloaded from the server.
function api.unloadData(player: Player)
    return store:unload(player):andThen(function()
        profiles[player] = nil
    end):catch(function(errorMsg)
        broadcastError("unloadData", errorMsg)
    end)
end

--- Checks if the player's data is active in the server.
--- This is recommended to check if there is an active data before retrieving it.
function api.hasActiveData(player: Player)
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

--- Retrieves player's data.
--- The player's data needs to be loaded first via `api.loadData(player)`
function api.getWholeData(player: Player)
    local profileData = profiles[player]
    if profileData then
        return profileData
    end
    local retrievedData = store:getAsync(player)
    cachePlayerData(player, retrievedData)
    return retrievedData
end

--- Resets the player data based on the latest version.
function api.resetData(player: Player)
    return store:updateImmutable(player, function(_data: PlayerData): PlayerData | false
        return Table.deepCopy(Template.playerData)
    end)
    :andThen(function()
        local newData = store:getAsync(player)
        cachePlayerData(player, newData)
    end)
    :catch(function(errorMsg)
        broadcastError("resetData", errorMsg)
    end)
end

--- Reconciles player data by filling missing data.
--- Does not work with legacy data.
function api.reconcileData(player: Player)
    return store:update(player, function(data: PlayerData): boolean
        local function reconcile(target: {[any]: any}, source: {[any]: any})
            for k, v in source do
                if target[k] == nil then
                    target[k] = if type(v) == "table" then Table.deepCopy(v) else v
                elseif type(target[k]) == "table" and type(v) == "table" then
                    reconcile(target[k], v)
                end
            end
        end
        reconcile(data :: any, Template.playerData :: any)
        cachePlayerData(player, data)
        return true
    end):catch(function(errorMsg)
        broadcastError("reconcileData", errorMsg)
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

--- Returns the current save slot of player.
--- If the selected save slot is `0`, then the api will return `nil`.
function api.getCurrentSaveSlot(player: Player): SaveSlot?
    return api.getSaveSlot(player)
end

--- Sets the current selected save slot index.
function api.setSelectedSaveSlot(player: Player, index: number)
    return store:update(player, function(playerData: PlayerData)
        if index < 1 or index > Template.maxSaveSlots then
            warn(`The save slot selection index must be between {1} and {Template.maxSaveSlots}. Index: {index}`)
            return false
        end

        playerData.selectedSaveSlot = index
        cachePlayerData(player, playerData)
        return true
    end)
    :catch(function(errorMsg: string)
        broadcastError("setSelectedSaveSlot", errorMsg)
    end)
end

function api.createNewSlot(player: Player)
    return 
end

--- Sugar for `store:update()`. Usually handled by other APIs.
--- Returns a promise after the confirmation of the change.
function api.updateData(player: Player, transformFunction: (currentData: PlayerData) -> boolean)
    return store:update(player, transformFunction)
    :andThen(function()
        local newData = store:getAsync(player)
        cachePlayerData(player, newData)
    end)
    :catch(function(errorMsg: string)
        broadcastError("updateData", errorMsg)
    end)
end

--- Updates a save slot by index, or the currently selected save slot if no index is provided.
function api.updateSaveSlot(player: Player, transformFunc: TransformSaveslotFunc, index: number?)
    return store:update(player, function(data: PlayerDataTyping.PlayerData): boolean
        local activeSaveSlots = getSaveSlots(data.saveSlots, false)
        local resolvedIndex = index or data.selectedSaveSlot
        local result = transformFunc(activeSaveSlots[resolvedIndex])

        if result then
            cachePlayerData(player, data)
        end

        return result
    end)
    :catch(function(errorMsg: string)
        broadcastError("updateSaveSlot", errorMsg)
    end)
end

--- Returns a string formatted version of player data.
--- Example: `V1.0.0`.
function api.getMainStringVersion(player: Player)
    local saveSlot = api.getWholeData(player)
    return Migration.versionToString(saveSlot.dataVersion)
end

--- Returns the string version of the index's active save slot.
--- Example: `V1.0.0`.
function api.getClassStringVersion(player: Player, index: number)
    local saveSlot = api.getSaveSlot(player, index)
    local versionToFormat = saveSlot.dataVersion or Version
    return Migration.versionToString(versionToFormat)
end

--[[ Initialisation ]]

dataAccessor.get = api.getWholeData
dataAccessor.update = api.updateData
dataAccessor.getSaveSlot = api.getSaveSlot
dataAccessor.updateSaveSlot = api.updateSaveSlot

Promise.each(script:GetChildren(), function(module: ModuleScript, index: number)
    return Promise.new(function(resolve, reject, onCancel)
        local moduleData = require(module)

        moduleData.init(dataAccessor)
        resolve()
    end)
end)
:catch(function(errorMsg: string)
    broadcastError("PlayerDataAPI init", errorMsg)
end)

return table.freeze(api)
