local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = ReplicatedStorage.Constants.Enums

local BitsEnum = require(Enums.Bits)
local PerksEnum = require(Enums.Perks)

local QuestTyping = require(script.Parent.Quest)

local t = require(ReplicatedStorage.Packages.t)
local Lync = require(ReplicatedStorage.Packages.Lync)

export type PlayerClassData = {
    expPoints: number,
    perks: { [string]: { quantity: number } },
    quests: QuestTyping.QuestProgressMap,
}

local typing = {}

typing.perksDataT = t.strictInterface({
    quantity = t.number,
})

typing.playerClassDataT = t.strictInterface({
    expPoints = t.number,
    perks = t.map(t.string, typing.perksDataT),
    quests = QuestTyping.questProgressMapT,
})

typing.perksDataLync = Lync.struct({
    quantity = Lync.int(0, PerksEnum.maxPerkValue),
})

typing.playerClassDataLync = Lync.struct({
    expPoints = BitsEnum.f64Lync,
    perks = Lync.map(Lync.string, typing.perksDataLync),
    quests = QuestTyping.questProgressMapLync,
})

return table.freeze(typing)
