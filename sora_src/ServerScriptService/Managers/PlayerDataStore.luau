local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Initializer = require(ReplicatedStorage.Constants.Typing.Initializer)
local DataStoreAPI = require(ServerScriptService.API.PlayerData)

local function onPlayerAdded(player: Player)
    DataStoreAPI.loadData(player)
    :andThen(function()
        -- Test only.
        if DataStoreAPI.getDataStoreName() == "CF_Dev" then
            print(`Player '{player.Name}' is currently in dev place, resetting data.`)
            DataStoreAPI.resetData(player)
        end

        print(`Successfully loaded {player.Name}'s data. Here's their data.`)
        print(DataStoreAPI.getWholeData(player))
    end)
    :catch(function(errorMessage: string)
        print(`Failed to load {player.Name}'s data.`)
    end)
end

local function onPlayerRemoving(player: Player)
    if not DataStoreAPI.hasActiveData(player) then
        return
    end

    DataStoreAPI.unloadData(player)
    :andThen(function()
        if player:IsDescendantOf(Players) then
            player:Kick("Your data has been released from the server, kicking you out.")
        end
        
        print(`Successfully unloaded {player.Name}'s data.`)
    end)        
end

local content = {} :: Initializer.Module

function content.start()
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)

    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end

    return {
        isSuccess = true
    }
end

return table.freeze(content)