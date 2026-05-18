local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = ReplicatedStorage.Constants.Enums

local BitsEnum = require(Enums.Bits)

local ClassTyping = require(script.Parent.Class)
local StatPointsTyping = require(script.Parent.StatPoints)
local CurrenciesTyping = require(script.Parent.Currencies)
local ItemTyping = require(script.Parent.Item)
local QuestTyping = require(script.Parent.Quest)
local StatisticsTyping = require(script.Parent.Statistics)

local t = require(ReplicatedStorage.Packages.t)
local Lync = require(ReplicatedStorage.Packages.Lync)

export type DataVersion = { [number]: number }

export type SaveSlot = {
    name: string,
    currencies: { [CurrenciesTyping.SlotCurrency]: number },
    materials: { [string]: number },
    expPoints: number,
    selectedItems: {
        normal: { number },
        cosmetic: { string },
    },
    inventory: ItemTyping.InventoryData,
    classes: { [string]: ClassTyping.PlayerClassData },
    statPoints: { [string]: number },
    questRecurrences: { [QuestTyping.QuestRecurrenceType]: QuestTyping.QuestProgressMap },
    events: { [string]: QuestTyping.EventData },
    creationDate: number, -- formatted in UNIX time
    playTime: number,
    isArchived: boolean,
    archiveDate: number, -- formatted in UNIX time
    dataVersion: DataVersion,
    statistics: StatisticsTyping.StatisticsData,
}

local typing = {}

typing.dataVersionT = t.map(t.number, t.number)

typing.saveSlotT = t.strictInterface({
    name = t.string,
    currencies = CurrenciesTyping.currenciesDataT,
    materials = t.map(t.string, t.number),
    expPoints = t.number,
    selectedItems = ItemTyping.selectedItemsT,
    inventory = ItemTyping.inventoryT,
    classes = t.map(t.string, ClassTyping.playerClassDataT),
    statPoints = StatPointsTyping.statPointsT,
    questRecurrences = QuestTyping.questRecurrencesT,
    events = t.map(t.string, QuestTyping.eventDataT),
    creationDate = t.number,
    playTime = t.number,
    isArchived = t.boolean,
    archiveDate = t.number,
    dataVersion = typing.dataVersionT,
    statistics = StatisticsTyping.statisticsDataT,
})

typing.dataVersionLync = Lync.map(Lync.int(1, 3), Lync.int(0, 1000))

typing.saveSlotLync = Lync.struct({
    name = Lync.string(50),
    currencies = CurrenciesTyping.currenciesDataLync,
    materials = Lync.map(Lync.string, BitsEnum.u32Lync),
    expPoints = BitsEnum.f64Lync,
    selectedItems = ItemTyping.selectedItemsLync,
    inventory = ItemTyping.inventoryLync,
    classes = Lync.map(Lync.string, ClassTyping.playerClassDataLync),
    statPoints = StatPointsTyping.statPointsLync,
    questRecurrences = QuestTyping.questRecurrencesLync,
    events = Lync.map(Lync.string, QuestTyping.eventDataLync),
    creationDate = BitsEnum.f64Lync,
    playTime = BitsEnum.f64Lync,
    isArchived = Lync.bool,
    archiveDate = BitsEnum.f64Lync,
    dataVersion = typing.dataVersionLync,
    statistics = StatisticsTyping.statisticsDataLync,
})

return table.freeze(typing)
