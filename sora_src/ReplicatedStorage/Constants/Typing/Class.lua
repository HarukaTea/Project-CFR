local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Typing = require(ReplicatedStorage.Constants.Typing.PlayerData)

type PlayerData = Typing.PlayerData
type SaveSlot = Typing.SaveSlot

export type QuestData = {
    title: string,
    description: string,
    requirements: { [string]: (playerData: PlayerData, saveSlot: SaveSlot) -> boolean },
}

export type ClassData = {
    name: string,
    quests: { [string]: QuestData },
}

return {}