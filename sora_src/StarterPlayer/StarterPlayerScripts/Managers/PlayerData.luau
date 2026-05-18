local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = ReplicatedStorage.Network
local Client = ReplicatedStorage.Client

local Initializer = require(ReplicatedStorage.Constants.Typing:WaitForChild("Initializer"))

local ClientNetwork = require(Network:WaitForChild("ClientInit"))
local ServerNetwork = require(Network:WaitForChild("ServerInit"))
local PlayerDataNetwork = require(Network:WaitForChild("PlayerData"))

local PlayerDataAPI = require(ReplicatedStorage.Shared.API.PlayerData)

local content = {} :: Initializer.Module

function content.start()
    print(`{script.Name} is now starting and requesting player data.`)

    return {
        isSuccess = true,
    }
end

return table.freeze(content)