local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = require(ReplicatedStorage.Constants.Typing.PlayerData)
local t = require(ReplicatedStorage.Packages.t)

-- Re-export shared types so server code only needs to require this file.
export type StatType = Typing.StatType
export type ClassType = Typing.ClassType
export type CosmeticType = Typing.CosmeticType
export type InventoryType = Typing.InventoryType
export type BaseCurrencyType = Typing.BaseCurrencyType
export type QuestRecurrenceType = Typing.QuestRecurrenceType
export type PurchaseType = Typing.PurchaseType
export type QuestData = Typing.QuestData
export type RobuxTransaction = Typing.RobuxTransaction
export type ClassData = Typing.ClassData
export type EventData = Typing.EventData
export type InventoryData = Typing.InventoryData
export type DataVersion = Typing.DataVersion
export type SaveSlot = Typing.SaveSlot
export type PlayerData = Typing.PlayerData

local typing = {}

typing.questDataT = t.map(t.string, t.number)

typing.perksDataT = t.strictInterface({
    quantity = t.number
})

typing.classDataT = t.strictInterface({
    expPoints = t.number,
    perks = t.map(t.string, typing.perksDataT),
    quests = typing.questDataT,
})

typing.currenciesDataT = t.strictInterface({
    gold = t.number,
})

typing.eventDataT = t.strictInterface({
    currencyPoints = t.optional(t.number),
    quests = typing.questDataT,
})

typing.questRecurrencesT = t.strictInterface({
    daily = typing.questDataT,
    weekly = typing.questDataT,
    monthly = typing.questDataT,
})

typing.itemInstanceT = t.map(t.string, t.number)
typing.inventoryDataT = t.map(t.string, typing.itemInstanceT)
typing.inventoryT = t.map(t.string, typing.inventoryDataT)

typing.dataVersionT = t.map(t.number, t.number)

typing.dataSlotT = t.strictInterface({
    name = t.string,
    currencies = typing.currenciesDataT,
    expPoints = t.number,
    inventory = typing.inventoryT,
    classes = t.map(t.string, typing.classDataT),
    statPoints = t.map(t.string, t.number),
    questRecurrences = typing.questRecurrencesT,
    events = t.map(t.string, typing.eventDataT),
    creationDate = t.number,
    playTime = t.number,
    isArchived = t.boolean,
    archiveDate = t.number,
    dataVersion = typing.dataVersionT
})

typing.robuxTransactionT = t.strictInterface({
    productName = t.string,
    purchaseDate = t.number,
    priceAmount = t.number,
})

typing.schema = t.strictInterface({
    selectedSaveSlot = t.number,
    cosmetics = t.map(t.string, t.array(t.string)),
    saveSlots = t.array(typing.dataSlotT),
    robuxPurchases = t.strictInterface({
        devProducts = t.array(typing.robuxTransactionT),
        gamePasses = t.array(typing.robuxTransactionT),
    }),
    settings = t.map(t.string, t.number),
    joinDate = t.number,
    dataVersion = typing.dataVersionT,
})

return table.freeze(typing)