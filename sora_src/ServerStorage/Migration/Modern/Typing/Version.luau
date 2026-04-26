local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Typing = require(ReplicatedStorage.Constants.Typing.PlayerData)

type PlayerData = Typing.PlayerData

export type VersionModule = {
    --- Transform the player data to the version's ideal data.
    transform: (playerData: PlayerData) -> PlayerData,
}

return {}