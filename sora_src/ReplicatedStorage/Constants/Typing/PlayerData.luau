local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Typing = ReplicatedStorage.Constants.Typing

local Properties = require(Typing.Properties)
local SettingTyping = require(Typing.PlayerSettings)
local t = require(ReplicatedStorage.Packages.t)
local LyncTyping = require(ReplicatedStorage.Constants.Typing.Lync)
local Lync = require(ReplicatedStorage.Packages.Lync) :: LyncTyping.LyncLib

type AllProperties = Properties.AllProperties
type SettingName = SettingTyping.SettingName

export type StatType = "str" | "agi" | "int" | "vit" | "dex"
export type CosmeticType = "armors" | "titles" | "weapons"
export type InventoryType = "weapons" | "accessories" | "armors"
export type BaseCurrencyType = "gold"
export type QuestRecurrenceType = "daily" | "weekly" | "monthly"
export type PurchaseType = "devProducts" | "gamePasses"
export type GlobalCurrency = "astral"

export type QuestData = {
    [string]: number,
}

export type EventData = {
    currencyPoints: number?,
    quests: QuestData,
}

export type DataVersion = {
    [number]: number,
}

export type RobuxTransaction = {
    productName: string,
    purchaseDate: number,
    priceAmount: number,
}

export type ClassData = {
    expPoints: number,
    perks: { [string]: { quantity: number } },
    quests: QuestData,
}

--- The property number is usually between 0 and 1.
--- 0 is being the minimum value while
--- 1 is the maximum value.
--- It can go below 0 or above 1 for testing purposes.
export type ItemData = {
    type: "test" | "release",
    id: number,
    properties: { [AllProperties]: number },
    obtainedAt: number, -- UNIX time
}

export type InventoryData = {
    --- separated by item name
    [string]: { ItemData }
}

export type SaveSlot = {
    name: string,
    currencies: { [BaseCurrencyType]: number },
    materials: { [string]: number },
    expPoints: number,
    selectedItems: { [InventoryType]: { number } },
    inventory: { [InventoryType]: InventoryData },
    classes: { [string]: ClassData },
    statPoints: { [StatType]: number },
    questRecurrences: { [QuestRecurrenceType]: QuestData },
    events: { [string]: EventData },
    creationDate: number, -- formatted in UNIX time
    playTime: number,
    isArchived: boolean,
    archiveDate: number, -- formatted in UNIX time
    dataVersion: DataVersion,
}

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
    --- Used as a local data UID. This will increment every time the player gains a new item, excluding materials (they don't need UIDs)
    itemsGained: number,
}

export type PlayerData = {
    selectedSaveSlot: number, -- 0 if the player is new
    globalCurrencies: { [GlobalCurrency]: number },
    cosmetics: { [CosmeticType]: { string } },
    robuxPurchases: { [PurchaseType]: { RobuxTransaction } },
    settings: { [SettingName]: number },
    saveSlots: { SaveSlot },
    joinDate: number, -- formatted in UNIX time
    dataVersion: DataVersion,
    internal: InternalData, -- do not touch!!!
}

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

typing.selectedItemsT = t.map(t.string, t.array(t.number))

typing.itemDataT = t.strictInterface({
    type = t.union(t.literal("test"), t.literal("release")),
    id = t.number,
    properties = t.map(t.string, t.number),
    obtainedAt = t.number,
})
typing.inventoryDataT = t.map(t.string, t.array(typing.itemDataT))
typing.inventoryT = t.map(t.string, typing.inventoryDataT)

typing.dataVersionT = t.map(t.number, t.number)

typing.dataSlotT = t.strictInterface({
    name = t.string,
    currencies = typing.currenciesDataT,
    materials = t.map(t.string, t.number),
    expPoints = t.number,
    selectedItems = typing.selectedItemsT,
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

typing.schema = t.strictInterface({
    selectedSaveSlot = t.number,
    globalCurrencies = t.map(t.string, t.number),
    cosmetics = t.map(t.string, t.array(t.string)),
    saveSlots = t.array(typing.dataSlotT),
    robuxPurchases = t.strictInterface({
        devProducts = t.array(typing.robuxTransactionT),
        gamePasses = t.array(typing.robuxTransactionT),
    }),
    settings = t.map(t.string, t.number),
    joinDate = t.number,
    dataVersion = typing.dataVersionT,
    --- Internal shouldn't be visible to the non-mods.
    internal = t.optional(typing.internalDataT),
})

-- Lync codecs
local MAX_FLOAT: number = 2 ^ 64
local PRECISION: number = 0.1

typing.questDataLync = Lync.map(Lync.string, Lync.int(0, 10000))

typing.perksDataLync = Lync.struct({
    quantity = Lync.int(0, 20),
})

typing.classDataLync = Lync.struct({
    expPoints = Lync.float(0, MAX_FLOAT, 1),
    perks = Lync.map(Lync.string, typing.perksDataLync),
    quests = typing.questDataLync,
})

typing.currenciesDataLync = Lync.struct({
    gold = Lync.float(0, MAX_FLOAT, 1),
})

typing.eventDataLync = Lync.struct({
    currencyPoints = Lync.optional(Lync.float(0, MAX_FLOAT, 1)),
    quests = typing.questDataLync,
})

typing.questRecurrencesLync = Lync.struct({
    daily = typing.questDataLync,
    weekly = typing.questDataLync,
    monthly = typing.questDataLync,
})

typing.selectedItemsLync = Lync.map(Lync.string, Lync.array(Lync.int(0, 1000)))

typing.itemDataLync = Lync.struct({
    type = Lync.enum("test", "release"),
    id = Lync.int(0, 2^24),
    properties = Lync.map(Lync.string, Lync.float(0, 1, 0.001)),
    obtainedAt = Lync.float(0, MAX_FLOAT, PRECISION),
})

typing.inventoryDataLync = Lync.map(Lync.string, Lync.array(typing.itemDataLync))

typing.inventoryLync = Lync.map(Lync.string, typing.inventoryDataLync)

typing.dataVersionLync = Lync.map(Lync.int(0, 1000), Lync.int(0, 1000))

typing.dataSlotLync = Lync.struct({
    name = Lync.string(50),
    currencies = typing.currenciesDataLync,
    materials = Lync.map(Lync.string, Lync.int(0, 1000000)),
    expPoints = Lync.float(0, MAX_FLOAT, 1),
    selectedItems = typing.selectedItemsLync,
    inventory = typing.inventoryLync,
    classes = Lync.map(Lync.string, typing.classDataLync),
    statPoints = Lync.map(Lync.string, Lync.int(0, 1000)),
    questRecurrences = typing.questRecurrencesLync,
    events = Lync.map(Lync.string, typing.eventDataLync),
    creationDate = Lync.float(0, MAX_FLOAT, PRECISION),
    playTime = Lync.float(0, MAX_FLOAT, PRECISION),
    isArchived = Lync.bool,
    archiveDate = Lync.float(0, MAX_FLOAT, PRECISION),
    dataVersion = typing.dataVersionLync,
})

typing.robuxTransactionLync = Lync.struct({
    productName = Lync.string(200),
    purchaseDate = Lync.float(0, MAX_FLOAT, PRECISION),
    priceAmount = Lync.int(0, 1000000),
})

typing.automatedLogDataLync = Lync.struct({
    severity = Lync.int(0, 10),
    description = Lync.string(500),
    dateStarted = Lync.float(0, MAX_FLOAT, PRECISION),
    duration = Lync.float(0, MAX_FLOAT, PRECISION),
})

typing.internalDataLync = Lync.struct({
    automatedLogs = Lync.array(typing.automatedLogDataLync),
    itemsGained = Lync.int(0, 2^24),
})

typing.schemaLync = Lync.struct({
    selectedSaveSlot = Lync.int(0, 10),
    globalCurrencies = Lync.map(Lync.string, Lync.float(0, MAX_FLOAT, 1)),
    cosmetics = Lync.map(Lync.string, Lync.array(Lync.string)),
    saveSlots = Lync.array(typing.dataSlotLync),
    robuxPurchases = Lync.struct({
        devProducts = Lync.array(typing.robuxTransactionLync),
        gamePasses = Lync.array(typing.robuxTransactionLync),
    }),
    settings = Lync.map(Lync.string, Lync.float(0, 10, 0.01)),
    joinDate = Lync.float(0, MAX_FLOAT, PRECISION),
    dataVersion = typing.dataVersionLync,
    --- Must be hidden from non-mods
    internal = Lync.optional(typing.internalDataLync),
})

return table.freeze(typing)
