local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = ReplicatedStorage.Constants.Enums

local BitsEnums = require(Enums.Bits)

local Lync = require(ReplicatedStorage.Packages.Lync)

type QuestDetails = {
    class: string,
    questName: string,
}

export type QuestUpdatedPayload = {
    newValue: number,
} & QuestDetails

export type QuestFinishedPayload = QuestDetails

local remoteSignals = {}

--- Client selects a quest with the quest name (must follow camelCase naming convention).
remoteSignals.selectQuest = Lync.packet("selectQuest", Lync.string)

remoteSignals.questObtained = Lync.packet("questObtained", Lync.string)

remoteSignals.questUpdated = Lync.packet("questUpdated", Lync.struct({
    questName = Lync.string,
    newValue = BitsEnums.i32Lync,
}))

remoteSignals.questFinished = Lync.packet("questFinished", Lync.struct({
    questName = Lync.string,
}))

remoteSignals.requestQuest = Lync.packet("requestQuest", Lync.string)

return table.freeze(remoteSignals)