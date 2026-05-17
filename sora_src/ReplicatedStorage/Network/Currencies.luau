local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local LyncTyping = require(Typing.Lync)
local PlayerDataTyping = require(Typing.PlayerData)

local BitsEnums = require(Enums.Bits)
local CurrencyEnums = require(Enums.Currencies)

local Lync = require(ReplicatedStorage.Packages.Lync)

export type SpecialCurrenciesPayload = {
    [PlayerDataTyping.SpecialCurrency]: number
}

export type SlotCurrenciesPayload = {
    [PlayerDataTyping.SlotCurrency]: number
}

local remoteSignals = {}

remoteSignals.specialCurrenciesUpdated = Lync.packet("specialCurrenciesUpdated", Lync.deltaMap(Lync.enum(unpack(CurrencyEnums.specialCurrencies)), BitsEnums.f64Lync)) :: LyncTyping.Packet<SpecialCurrenciesPayload>

remoteSignals.slotCurrenciesUpdated = Lync.packet("slotCurrenciesUpdated", Lync.deltaMap(Lync.enum(unpack(CurrencyEnums.slotCurrencies)), BitsEnums.f64Lync)) :: LyncTyping.Packet<SlotCurrenciesPayload>

return table.freeze(remoteSignals)