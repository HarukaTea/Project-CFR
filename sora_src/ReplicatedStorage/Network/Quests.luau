local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local LyncTyping = require(Typing.Lync)

local BitsEnums = require(Enums.Bits)

local Lync = require(ReplicatedStorage.Packages.Lync)

export type QuestUpdatedPayload = {
    questName: string,
    oldValue: number,
    newValue: number,
}

export type QuestFinishedPayload = {
    questName: string,
}

local remoteSignals = {}

--- Client selects a quest with the quest name (must follow camelCase naming convention).
remoteSignals.requestQuest = Lync.packet("selectQuest", Lync.string) :: LyncTyping.Packet<string>

remoteSignals.questsUpdated = Lync.packet("questsUpdated", Lync)

remoteSignals.questUpdated = Lync.packet("questUpdated", Lync.struct({
    questName = Lync.string,
    oldValue = BitsEnums.u16Lync,
    newValue = BitsEnums.u16Lync,
})) :: LyncTyping.Packet<QuestUpdatedPayload>


remoteSignals.questFinished = Lync.packet("questFinished", Lync.struct({
    questName = Lync.string,
})) :: LyncTyping.Packet<QuestFinishedPayload>

return table.freeze(remoteSignals)