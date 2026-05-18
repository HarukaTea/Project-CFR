local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local SettingTyping = require(Typing.PlayerSettings)

local BitsEnum = require(Enums.Bits)
local CurrenciesEnum = require(Enums.Currencies)
local SaveSlotsEnum = require(Enums.SaveSlots)

local QuestTyping = require(script.Quest)
local ClassTyping = require(script.Class)
local ItemTyping = require(script.Item)
local StatisticsTyping = require(script.Statistics)
local InternalTyping = require(script.Internal)
local CurrenciesTyping = require(script.Currencies)
local SaveSlotTyping = require(script.SaveSlot)

local t = require(ReplicatedStorage.Packages.t)
local Lync = require(ReplicatedStorage.Packages.Lync)

type SettingName = SettingTyping.SettingName

-- Re-export sub-module types for backward compatibility
export type QuestProgressMap = QuestTyping.QuestProgressMap
export type QuestRecurrenceType = QuestTyping.QuestRecurrenceType
export type EventData = QuestTyping.EventData
export type PlayerClassData = ClassTyping.PlayerClassData
export type InventoryType = ItemTyping.InventoryType
export type ItemData = ItemTyping.ItemData
export type InventoryData = ItemTyping.InventoryData
export type StatisticsDamageData = StatisticsTyping.StatisticsDamageData
export type StatisticsHealData = StatisticsTyping.StatisticsHealData
export type StatisticsData = StatisticsTyping.StatisticsData
export type AutomatedLogData = InternalTyping.AutomatedLogData
export type InternalData = InternalTyping.InternalData
export type SlotCurrency = CurrenciesTyping.SlotCurrency
export type SpecialCurrency = CurrenciesTyping.SpecialCurrency
export type PurchaseType = CurrenciesTyping.PurchaseType
export type RobuxTransaction = CurrenciesTyping.RobuxTransaction
export type DataVersion = SaveSlotTyping.DataVersion
export type SaveSlot = SaveSlotTyping.SaveSlot

-- Backward-compat aliases for renamed types
export type ClassData = ClassTyping.PlayerClassData
export type QuestData = QuestTyping.QuestProgressMap

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

typing.automatedLogDataT = InternalTyping.automatedLogDataT
typing.internalDataT = InternalTyping.internalDataT

typing.schema = t.strictInterface({
    selectedSaveSlot = t.number,
    specialCurrencies = t.map(t.string, t.number),
    cosmetics = t.array(t.string),
    saveSlots = t.array(SaveSlotTyping.saveSlotT),
    robuxPurchases = t.strictInterface({
        devProducts = t.array(CurrenciesTyping.robuxTransactionT),
        gamePasses = t.array(CurrenciesTyping.robuxTransactionT),
    }),
    settings = t.map(t.string, t.number),
    joinDate = t.number,
    dataVersion = SaveSlotTyping.dataVersionT,
    --- Internal shouldn't be visible to the non-mods.
    internal = t.optional(InternalTyping.internalDataT),
})

typing.schemaLync = Lync.struct({
    selectedSaveSlot = Lync.int(0, SaveSlotsEnum.maxSaveSlots),
    specialCurrencies = Lync.map(Lync.enum(unpack(CurrenciesEnum.specialCurrencies)), BitsEnum.f64Lync),
    cosmetics = Lync.array(Lync.string),
    saveSlots = Lync.array(SaveSlotTyping.saveSlotLync),
    robuxPurchases = Lync.struct({
        devProducts = Lync.array(CurrenciesTyping.robuxTransactionLync),
        gamePasses = Lync.array(CurrenciesTyping.robuxTransactionLync),
    }),
    settings = Lync.map(Lync.string, BitsEnum.f16Lync),
    joinDate = BitsEnum.f64Lync,
    dataVersion = SaveSlotTyping.dataVersionLync,
    internal = Lync.optional(InternalTyping.internalDataLync),
})

return table.freeze(typing)
