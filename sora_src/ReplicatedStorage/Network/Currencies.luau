local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local PlayerDataTyping = require(Typing.PlayerData)

local BitsEnums = require(Enums.Bits)
local CurrencyEnums = require(Enums.Currencies)
local SaveSlotsEnums = require(Enums.SaveSlots)

local Lync = require(ReplicatedStorage.Packages.Lync)

export type CurrenciesLoadedPayload = {
    specialCurrencies: { [string]: number },
    normalCurrencies: { [string]: number },
}

export type SpecialCurrencyPayload = {
    currencyName: PlayerDataTyping.SpecialCurrency,
    oldValue: number,
    newValue: number,
}

export type SlotCurrencyPayload = {
    currencyName: PlayerDataTyping.SlotCurrency,
    oldValue: number,
    newValue: number,
}

local remoteSignals = {}

remoteSignals.currenciesLoaded = Lync.packet("currenciesLoaded", Lync.struct({
    index = SaveSlotsEnums.maxSaveSlotsLync,
    specialCurrencies = Lync.map(Lync.string, BitsEnums.uf64Lync),
    normalCurrencies = Lync.map(Lync.string, BitsEnums.uf64Lync),
}))

remoteSignals.specialCurrencyUpdated = Lync.packet("specialCurrencyUpdated", Lync.struct({
    currencyName = Lync.enum(unpack(CurrencyEnums.specialCurrencies)),
    oldValue = BitsEnums.uf64Lync,
    newValue = BitsEnums.uf64Lync,
}))

remoteSignals.slotCurrencyUpdated = Lync.packet("slotCurrencyUpdated", Lync.struct({
    currencyName = Lync.enum(unpack(CurrencyEnums.normalCurrencies)),
    oldValue = BitsEnums.uf64Lync,
    newValue = BitsEnums.uf64Lync,
}))

return table.freeze(remoteSignals)