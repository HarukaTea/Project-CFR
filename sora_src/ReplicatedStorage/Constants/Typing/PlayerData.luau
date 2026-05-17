local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local PropertiesTyping = require(Typing.Properties)
local SettingTyping = require(Typing.PlayerSettings)
local TraitsTyping = require(Typing.Traits)

local PropertiesEnum = require(Enums.Properties)
local PerksEnum = require(Enums.Perks)
local BitsEnum = require(Enums.Bits)
local CurrenciesEnum = require(Enums.Currencies)

local t = require(ReplicatedStorage.Packages.t)
local Lync = require(ReplicatedStorage.Packages.Lync)

type AllProperties = PropertiesTyping.AllProperties
type SettingName = SettingTyping.SettingName

export type StatType = "str" | "agi" | "int" | "vit" | "dex"
export type InventoryType = "weapons" | "accessories" | "armors"
export type SlotCurrency = "gold"
export type QuestRecurrenceType = "daily" | "weekly" | "monthly"
export type PurchaseType = "devProducts" | "gamePasses"
export type SpecialCurrency = "astral"

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
    --- Based on Internal.itemsGained
    id: number,
    properties: { [AllProperties]: number },
    obtainedAt: number, -- UNIX time
}

export type InventoryData = {
    --- separated by item name
    [string]: { ItemData }
}

export type StatisticsDamageData = {
    totalPhysical: number,
    meleePhysical: number,
    rangePhysical: number,
    magical: number,
    poison: number,
    burn: number
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

export type SaveSlot = {
    name: string,
    currencies: { [SlotCurrency]: number },
    materials: { [string]: number },
    expPoints: number,
    selectedItems: {
        normal: { number },
        cosmetic: { string },
    },
    inventory: InventoryData,
    classes: { [string]: ClassData },
    statPoints: { [StatType]: number },
    questRecurrences: { [QuestRecurrenceType]: QuestData },
    events: { [string]: EventData },
    creationDate: number, -- formatted in UNIX time
    playTime: number,
    isArchived: boolean,
    archiveDate: number, -- formatted in UNIX time
    dataVersion: DataVersion,
    statistics: StatisticsData,
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
    specialCurrencies: { [SpecialCurrency]: number },
    cosmetics: { string },
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

typing.selectedItemsT = t.strictInterface({
    normal = t.array(t.number),
    cosmetic = t.array(t.string),
})

typing.itemDataT = t.strictInterface({
    type = t.union(t.literal("test"), t.literal("release")),
    id = t.number,
    properties = t.map(t.string, t.number),
    obtainedAt = t.number,
})
typing.inventoryT = t.map(t.string, t.array(typing.itemDataT))

typing.dataVersionT = t.map(t.number, t.number)

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

typing.saveSlotT = t.strictInterface({
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
    dataVersion = typing.dataVersionT,
    statistics = typing.statisticsDataT,
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
    specialCurrencies = t.map(t.string, t.number),
    cosmetics = t.array(t.string),
    saveSlots = t.array(typing.saveSlotT),
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

typing.questDataLync = Lync.map(Lync.string, BitsEnum.u16Lync)

typing.perksDataLync = Lync.struct({
    quantity = Lync.int(0, PerksEnum.maxPerkValue),
})

typing.classDataLync = Lync.struct({
    expPoints = BitsEnum.f64Lync,
    perks = Lync.map(Lync.string, typing.perksDataLync),
    quests = typing.questDataLync,
})

typing.currenciesDataLync = Lync.struct({
    gold = BitsEnum.f64Lync,
})

typing.eventDataLync = Lync.struct({
    currencyPoints = Lync.optional(BitsEnum.f64Lync),
    quests = typing.questDataLync,
})

typing.questRecurrencesLync = Lync.struct({
    daily = typing.questDataLync,
    weekly = typing.questDataLync,
    monthly = typing.questDataLync,
})

typing.selectedItemsLync = Lync.struct({
    normal = Lync.array(BitsEnum.u32Lync),
    cosmetic = Lync.array(Lync.string),
})

typing.itemDataLync = Lync.struct({
    type = Lync.enum("test", "release"),
    id = BitsEnum.u32Lync,
    properties = Lync.map(Lync.string, Lync.float(
        PropertiesEnum.maxRangePercentages.min,
        PropertiesEnum.maxRangePercentages.max,
        0.001
    )),
    obtainedAt = BitsEnum.f64Lync,
})

typing.inventoryLync = Lync.map(Lync.string, Lync.array(typing.itemDataLync))

typing.dataVersionLync = Lync.map(Lync.int(1, 3), Lync.int(0, 1000))

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

typing.statTypeLync = Lync.enum("str", "agi", "int", "vit", "dex")

typing.saveSlotLync = Lync.struct({
    name = Lync.string(50),
    currencies = typing.currenciesDataLync,
    materials = Lync.map(Lync.string, BitsEnum.u32Lync),
    expPoints = BitsEnum.f64Lync,
    selectedItems = typing.selectedItemsLync,
    inventory = typing.inventoryLync,
    classes = Lync.map(Lync.string, typing.classDataLync),
    statPoints = Lync.map(typing.statTypeLync, BitsEnum.i16Lync),
    questRecurrences = typing.questRecurrencesLync,
    events = Lync.map(Lync.string, typing.eventDataLync),
    creationDate = BitsEnum.f64Lync,
    playTime = BitsEnum.f64Lync,
    isArchived = Lync.bool,
    archiveDate = BitsEnum.f64Lync,
    dataVersion = typing.dataVersionLync,
    statistics = typing.statisticsDataLync,
})

typing.robuxTransactionLync = Lync.struct({
    productName = Lync.string(200),
    purchaseDate = BitsEnum.f64Lync,
    priceAmount = Lync.int(0, 1_000_000),
})

typing.automatedLogDataLync = Lync.struct({
    severity = Lync.int(0, 10),
    description = Lync.string(500),
    dateStarted = BitsEnum.f64Lync,
    duration = BitsEnum.f64Lync,
})

typing.internalDataLync = Lync.struct({
    automatedLogs = Lync.array(typing.automatedLogDataLync),
    itemsGained = Lync.int(0, 2^24),
})

typing.schemaLync = Lync.struct({
    selectedSaveSlot = Lync.int(0, 10),
    specialCurrencies = Lync.map(Lync.enum(unpack(CurrenciesEnum.specialCurrencies)), BitsEnum.f64Lync),
    cosmetics = Lync.array(Lync.string),
    saveSlots = Lync.array(typing.saveSlotLync),
    robuxPurchases = Lync.struct({
        devProducts = Lync.array(typing.robuxTransactionLync),
        gamePasses = Lync.array(typing.robuxTransactionLync),
    }),
    settings = Lync.map(Lync.string, BitsEnum.f16Lync),
    joinDate = BitsEnum.f64Lync,
    dataVersion = typing.dataVersionLync,
    --- Must be hidden from non-mods
    internal = Lync.optional(typing.internalDataLync),
})

return table.freeze(typing)
