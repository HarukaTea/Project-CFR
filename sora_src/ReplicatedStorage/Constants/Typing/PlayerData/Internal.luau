local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = ReplicatedStorage.Constants.Enums

local BitsEnum = require(Enums.Bits)

local t = require(ReplicatedStorage.Packages.t)
local Lync = require(ReplicatedStorage.Packages.Lync)

export type AutomatedLogData = {
    severity: number,
    description: string,
    --- UNIX time
    dateStarted: number,
    --- In seconds
    duration: number,
}

export type InternalData = {
    automatedLogs: { AutomatedLogData },
    --- Used as a local data UID. Increments every time the player gains a new item, excluding materials.
    itemsGained: number,
}

local typing = {}

typing.automatedLogDataT = t.strictInterface({
    severity = t.number,
    description = t.string,
    dateStarted = t.number,
    duration = t.number,
})

typing.internalDataT = t.strictInterface({
    automatedLogs = t.array(typing.automatedLogDataT),
    itemsGained = t.number,
})

typing.automatedLogDataLync = Lync.struct({
    severity = Lync.int(1, 10),
    description = Lync.string(500),
    dateStarted = BitsEnum.f64Lync,
    duration = BitsEnum.f64Lync,
})

typing.internalDataLync = Lync.struct({
    automatedLogs = Lync.array(typing.automatedLogDataLync),
    itemsGained = BitsEnum.u32Lync,
})

return table.freeze(typing)
