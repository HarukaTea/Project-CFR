local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Packages = ReplicatedStorage.Packages

local Template = require(ServerStorage.Constants.Templating.PlayerData)
local Typing = require(ServerStorage.Constants.Typing.PlayerData)
local DataStores = require(ServerStorage.Constants.Attributes.DataStore)
local Places = require(ReplicatedStorage.Constants.Attributes.Places)
local Network = require(ReplicatedStorage.Network.PlayerData)
local Version = require(ReplicatedStorage.Constants.Attributes.Version)

local Migration = require(ServerStorage.Migration)
local Lyra = require(Packages.lyra)

type PlayerData = Typing.PlayerData
type SaveSlot = Typing.SaveSlot

local api = {}
--- Caching player data so `store:get()` doesn't get used too much.
local profiles = {} :: {[Player]: PlayerData}

--- Returns the datastore based on the placeId.
function api.getDataStoreName(): string
    local currentPlaceId = game.PlaceId
    return DataStores.modern[currentPlaceId]
        or DataStores.modern[Places.devPlace]
end

local store = Lyra.createPlayerStore({
    name = api.getDataStoreName(),
    template = Template.basePlayerData,
    schema = Typing.schema,
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
function api.loadPlayerData(player: Player)
    return store:load(player)
end

--- Unloads player's data, making it inaccessible unless loaded via `api.loadPlayerData(player)`.
--- This will kick the player after the data is unloaded from the server.
function api.unloadPlayerData(player: Player)
    return store:unload(player)
end

--- Checks if the player's data is active in the server.
--- This is recommended to check if there is an active data before retrieving it.
function api.hasActiveData(player: Player)
    return api.getWholeData(player) ~= nil
end

--- Retrieves player's data.
--- The player's data needs to be loaded first via `api.loadPlayerData(player)`
function api.getWholeData(player: Player)
    local profileData = profiles[player]
    if profileData then
        return profileData
    end
    local retrievedData = store:getAsync(player)
    cachePlayerData(player, retrievedData)
    return retrievedData
end

function api.reconcileData(player: Player)
    
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

--- Returns the index's save slot from the player data.
function api.getSaveSlot(player: Player, index: number): SaveSlot?
    local playerData = api.getWholeData(player)
    local count: number = 1

    for _, saveSlot: SaveSlot in playerData.saveSlots do
        if saveSlot.isArchived then
            continue
        end

        if count == index then
            return saveSlot
        end

        count += 1
    end
end

--- Returns the current save slot of player.
--- If the selected save slot is `0`, then the api will return `nil`.
function api.getCurrentSaveSlot(player: Player): SaveSlot?
    local playerData = api.getWholeData(player)
    return api.getSaveSlot(player, playerData.selectedSaveSlot)
end

--- Sets the current selected save slot index.
function api.setSelectedSaveSlot(player: Player, index: string)
    return store:update(player, function(playerData: PlayerData)
        if index < 1 or index > Template.maxSaveSlots then
            warn(`The save slot selection index must be between {1} and {Template.maxSaveSlots}. Index: {index}`)
            return false
        end

        playerData.selectedSaveSlot = index
        return true
    end)
end

--- Sugar for `store:update()`. Usually handled by other APIs.
--- Returns a promise after the confirmation of the change.
function api.updatePlayerData(player: Player, transformFunction: (currentData: PlayerData) -> boolean)
    return store:update(player, transformFunction)
end

--- Returns a string formatted version of player data.
--- Example: `V1.0.0`.
function api.getMainStringVersion(player: Player)
    local saveSlot = api.getWholeData(player)
    return Migration.versionToString(saveSlot.dataVersion)
end

--- Returns the string version of the index's active save slot.
--- Example: `V1.0.0`.
function api.getClassStringVersion(player: Player, index: string)
    local saveSlot = api.getSaveSlot(player, index)
    local versionToFormat = saveSlot.dataVersion or Version
    return Migration.versionToString(versionToFormat)
end

return table.freeze(api)
