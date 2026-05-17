local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = ReplicatedStorage.Network

local PlayerDataNetwork = require(Network:WaitForChild("PlayerData"))

local inited = false
local api = {}

function api.init()
    if inited then
        return
    end

    PlayerDataNetwork.requestData:send()
    inited = true
end

return table.freeze(api)