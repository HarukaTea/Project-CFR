local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Typing = ReplicatedStorage.Constants.Typing

local Properties = require(Typing.Properties)
local SettingTyping = require(Typing.PlayerSettings)
local t = require(ReplicatedStorage.Packages.t)

type AllProperties = Properties.AllProperties
type SettingName = SettingTyping.SettingName

export type StatType = "str" | "agi" | "int" | "vit" | "dex"
export type ClassType = "base" | "variant" | "unique" | "dev"
export type CosmeticType = "armors" | "titles" | "weapons"
export type InventoryType = "weapons" | "accessories" | "armors" | "materials"
export type BaseCurrencyType = "gold"
export type QuestRecurrenceType = "daily" | "weekly" | "monthly"
export type PurchaseType = "devProducts" | "gamePasses"

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

--- The number is usually between 0 and 1.
--- 0 is being the minimum value while
--- 1 is the maximum value.
--- It can go below 0 or above 1 for testing purposes.
export type InventoryData = {
    [string]: { [AllProperties]: number },
}

export type SaveSlot = {
    name: string,
    currencies: { [BaseCurrencyType]: number },
    expPoints: number,
    inventory: { [InventoryType]: InventoryData },
    classes: { [ClassType]: ClassData },
    statPoints: { [StatType]: number },
    questRecurrences: { [QuestRecurrenceType]: QuestData },
    events: { [string]: EventData },
    creationDate: number, -- formatted in UNIX time
    playTime: number,
    isArchived: boolean,
    archiveDate: number, -- formatted in UNIX time
    dataVersion: DataVersion,
}

export type PlayerData = {
    selectedSaveSlot: number, -- 0 if the player is new
    cosmetics: { [CosmeticType]: { string } },
    robuxPurchases: { [PurchaseType]: { RobuxTransaction } },
    settings: {[SettingName]: number},
    saveSlots: {SaveSlot},
    joinDate: number, -- formatted in UNIX time
    dataVersion: DataVersion,
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
