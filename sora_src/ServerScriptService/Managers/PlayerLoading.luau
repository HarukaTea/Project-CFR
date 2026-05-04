local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = ReplicatedStorage.Network

local ClientNetwork = require(Network.ClientInit)
local Initializer = require(ReplicatedStorage.Constants.Typing.Initializer)

local content = {} :: Initializer.Module

local function onPlayerReady(data: nil, player: Player, timestamp: number)
    print(`The server has received {player.Name}'s signal and they are ready to start the game.`)
end

function content.start()
    ClientNetwork.clientLoaded:on(onPlayerReady)

    return {
        isSuccess = true,
    }
end

return table.freeze(content)