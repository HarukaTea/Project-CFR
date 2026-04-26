local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Typings = ReplicatedStorage.Constants.Typing
local PlayerDataTyping = require(Typings.PlayerData)
local QuestTyping = require(Typings.Quest)
local t = require(ReplicatedStorage.Packages.t)

type PlayerData = PlayerDataTyping.PlayerData
type SaveSlot = PlayerDataTyping.SaveSlot
type QuestData = QuestTyping.QuestData

export type ClassData = {
    name: string,
    description: string,
    quests: { [string]: QuestData },
}

local typing = {}

typing.ClassDataT = t.strictInterface({
    name = t.string,
    description = t.string,
    quests = t.map(t.string, QuestTyping.QuestDataT)
})

return table.freeze(typing)