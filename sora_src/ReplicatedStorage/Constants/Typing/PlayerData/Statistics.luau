local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local TraitsTyping = require(Typing.Traits)
local BitsEnum = require(Enums.Bits)

local t = require(ReplicatedStorage.Packages.t)
local Lync = require(ReplicatedStorage.Packages.Lync)

export type StatisticsDamageData = {
    totalPhysical: number,
    meleePhysical: number,
    rangePhysical: number,
    magical: number,
    poison: number,
    burn: number,
}

export type StatisticsHealData = {
    normal: number,
    overTime: number,
    --- Self heal from orbs
    regen: number,
}

type DamageStats<T> = {
    done: T,
    taken: T,
    absorbed: T,
    blocked: T,
    nullified: T,
}

type HealStats<T> = {
    done: T,
    taken: T,
}

export type StatisticsData = {
    itemsGained: number,
    kills: {
        --- Enemy name
        [string]: {
            [TraitsTyping.Traits]: number
        },
    },
    damages: DamageStats<StatisticsDamageData>,
    heals: HealStats<StatisticsHealData>,
}

local typing = {}

typing.statisticsDamageDataT = t.strictInterface({
    totalPhysical = t.number,
    meleePhysical = t.number,
    rangePhysical = t.number,
    magical = t.number,
    poison = t.number,
    burn = t.number,
})

typing.statisticsHealDataT = t.strictInterface({
    normal = t.number,
    overTime = t.number,
    regen = t.number,
})

typing.statisticsDataT = t.strictInterface({
    itemsGained = t.number,
    kills = t.map(t.string, t.map(t.string, t.number)),
    damages = t.strictInterface({
        done = typing.statisticsDamageDataT,
        taken = typing.statisticsDamageDataT,
        absorbed = typing.statisticsDamageDataT,
        blocked = typing.statisticsDamageDataT,
        nullified = typing.statisticsDamageDataT,
    }),
    heals = t.strictInterface({
        done = typing.statisticsHealDataT,
        taken = typing.statisticsHealDataT,
    }),
})

typing.statisticsDamageDataLync = Lync.struct({
    totalPhysical = BitsEnum.f64Lync,
    meleePhysical = BitsEnum.f64Lync,
    rangePhysical = BitsEnum.f64Lync,
    magical = BitsEnum.f64Lync,
    poison = BitsEnum.f64Lync,
    burn = BitsEnum.f64Lync,
})

typing.statisticsHealDataLync = Lync.struct({
    normal = BitsEnum.f64Lync,
    overTime = BitsEnum.f64Lync,
    regen = BitsEnum.f64Lync,
})

typing.statisticsDataLync = Lync.struct({
    itemsGained = BitsEnum.u32Lync,
    kills = Lync.map(Lync.string, Lync.map(Lync.string, BitsEnum.u32Lync)),
    damages = Lync.struct({
        done = typing.statisticsDamageDataLync,
        taken = typing.statisticsDamageDataLync,
        absorbed = typing.statisticsDamageDataLync,
        blocked = typing.statisticsDamageDataLync,
        nullified = typing.statisticsDamageDataLync,
    }),
    heals = Lync.struct({
        done = typing.statisticsHealDataLync,
        taken = typing.statisticsHealDataLync,
    }),
})

return table.freeze(typing)
