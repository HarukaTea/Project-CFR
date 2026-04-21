local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Typing = ReplicatedStorage.Constants.Typing

local ItemTyping = require(Typing.Item)
local SettingTyping = require(Typing.PlayerSettings)

type ItemProperties = ItemTyping.ItemProperties
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
    [string]: { [ItemProperties]: number },
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

return {}
