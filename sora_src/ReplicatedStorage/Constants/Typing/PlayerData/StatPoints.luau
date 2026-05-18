local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = ReplicatedStorage.Constants.Enums

local BitsEnum = require(Enums.Bits)
local StatPointsEnum = require(Enums.StatPoints)

local t = require(ReplicatedStorage.Packages.t)
local Lync = require(ReplicatedStorage.Packages.Lync)

local function getStatNames(): { string }
    local statNames = {}

    for _, details: StatDetails in StatPointsEnum.basicStats do
        table.insert(statNames, details.abbv)
    end
    
    return statNames
end

local function getStatsT()
    local statsT = {}

    for _, details: StatDetails in StatPointsEnum.basicStats do
        table.insert(statsT, t.literal(details.abbv))
    end

    return statsT
end

export type StatDetails = {
    abbv: string,
    full: string
}

export type StatType = "str" | "agi" | "int" | "vit" | "dex"

export type StatsData = {
    [StatType]: number,
}

local typing = {}

typing.statPointsT = t.union(unpack(getStatsT()))

typing.statTypeLync = Lync.enum(unpack(getStatNames()))

typing.statPointsLync = Lync.map(typing.statTypeLync, BitsEnum.u16Lync)

return table.freeze(typing)