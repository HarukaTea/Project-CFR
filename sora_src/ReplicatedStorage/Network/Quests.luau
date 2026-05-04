local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = require(ReplicatedStorage.Constants.Typing.Lync)
local Lync = require(ReplicatedStorage.Packages.Lync) :: Typing.LyncLib

type QuestDetails = {
    class: string,
    questName: string,
}

export type QuestUpdatedPayload = {
    newValue: number,
} & QuestDetails

export type QuestFinishedPayload = QuestDetails

local remoteSignals = {}

remoteSignals.questUpdated = Lync.packet("questUpdated", Lync.struct({
    class = Lync.string,
    questName = Lync.string,
    newValue = Lync.int(0, 10000),
})) :: Typing.Packet<QuestUpdatedPayload>

remoteSignals.questFinished = Lync.packet("questFinished", Lync.struct({
    class = Lync.string,
    questName = Lync.string
})) :: Typing.Packet<QuestFinishedPayload>



return table.freeze(remoteSignals)