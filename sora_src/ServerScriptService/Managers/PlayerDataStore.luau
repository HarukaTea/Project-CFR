local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local datastoreAPI = require(ServerScriptService.API.PlayerDataStore)

local function onPlayerAdded(player: Player)
    
end

local function onPlayerRemoving(player: Player)
    
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in Players:GetPlayers() do
    onPlayerAdded(player)
end
