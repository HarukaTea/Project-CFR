local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Constants = ServerStorage.Constants
local Packages = ReplicatedStorage.Packages

local Network = ReplicatedStorage.Network

local PlayerDataTemplate = require(Constants.Templating.PlayerData)
local PlayerDataTyping = require(Constants.Typing.PlayerData)
local DataStores = require(Constants.Attributes.DataStore)
local Lyra = require(Packages.lyra)

local PlayerDataNetwork = require(Network.PlayerData)

type PlayerData = PlayerDataTyping.PlayerData

local api = {}
local store = Lyra.createPlayerStore({
    name = api.getDataStoreName(),
    template = PlayerDataTemplate.basePlayerData,
    schema = PlayerDataTyping.schema,
    changedCallbacks = function(key: string, oldData: PlayerData, newData: PlayerData)
        
    end
})

-- Returns the datastore based on the placeId
function api.getDataStoreName(): string
    local currentPlaceId = game.PlaceId
    return DataStores.modern[currentPlaceId]
end

--- Loads player's data, making it accessible via `api.get(player)`.
function api.loadPlayerData(player: Player)
    return store:load(player)
end

--- Unloads player's data, making it inaccessible unless loaded via `api.loadPlayerData(player)`.
--- This will kick the player after the data is unloaded from the server.
function api.unloadPlayerData(player: Player)
    return store:unload(player)
    :andThen(function()
        if player:IsDescendantOf(Players) then
            player:Kick("Your data has been released from the server, kicking you out.")
        end
    end)        
end

--- Retrieves player's data.
--- The player's data needs to be loaded first via `api.loadPlayerData(player)`
function api.get(player: Player)
    return store:get(player)
end

return api
