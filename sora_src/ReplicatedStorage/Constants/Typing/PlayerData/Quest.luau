local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = ReplicatedStorage.Constants.Enums

local BitsEnum = require(Enums.Bits)

local t = require(ReplicatedStorage.Packages.t)
local Lync = require(ReplicatedStorage.Packages.Lync)

export type QuestProgressMap = {
    [string]: {
        progress: number,
        dateStarted: number,
    }
}
export type QuestRecurrenceType = "daily" | "weekly" | "monthly"

export type EventData = {
    currencyPoints: number?,
    quests: QuestProgressMap,
}

local typing = {}

typing.questEntryT = t.strictInterface({
    progress = t.number,
    dateStarted = t.number,
})

typing.questProgressMapT = t.map(t.string, typing.questEntryT)

typing.eventDataT = t.strictInterface({
    currencyPoints = t.optional(t.number),
    quests = typing.questProgressMapT,
})

typing.questRecurrencesT = t.strictInterface({
    daily = typing.questProgressMapT,
    weekly = typing.questProgressMapT,
    monthly = typing.questProgressMapT,
})

typing.questEntryLync = Lync.struct({
    progress = BitsEnum.u16Lync,
    dateStarted = BitsEnum.f64Lync,
})

typing.questProgressMapLync = Lync.map(Lync.string, typing.questEntryLync)

typing.eventDataLync = Lync.struct({
    currencyPoints = Lync.optional(BitsEnum.f64Lync),
    quests = typing.questProgressMapLync,
})

typing.questRecurrencesLync = Lync.struct({
    daily = typing.questProgressMapLync,
    weekly = typing.questProgressMapLync,
    monthly = typing.questProgressMapLync,
})

return table.freeze(typing)
