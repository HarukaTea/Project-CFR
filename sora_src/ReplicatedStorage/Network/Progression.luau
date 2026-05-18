local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local LyncTyping = require(Typing.Lync)
local PlayerDataTyping = require(Typing.PlayerData)
local SaveSlotsTyping = require(Typing.SaveSlots)

local BitsEnums = require(Enums.Bits)

local Lync = require(ReplicatedStorage.Packages.Lync)

export type SaveSlotLoadedPayload = {
    index: number,
    data: PlayerDataTyping.SaveSlot,
}

export type PlayerExpUpdatedPayload = {
    index: number,
    oldExp: number,
    newExp: number,
}

export type StatPointsUpdatedPayload = {
    str: number?,
    agi: number?,
    int: number?,
    vit: number?,
    dex: number?,
}

local remoteSignals = {}

remoteSignals.playerExpUpdated = Lync.packet("playerExpUpdated", Lync.struct({
    index = SaveSlotsTyping.maxSaveSlotsLync,
    oldExp = BitsEnums.f64Lync,
    newExp = BitsEnums.f64Lync,
})) :: LyncTyping.Packet<PlayerExpUpdatedPayload>

remoteSignals.statPointsUpdated = Lync.packet("statPointsUpdated", Lync.deltaMap(Lync.string, BitsEnums.u16Lync)) :: LyncTyping.Packet<StatPointsUpdatedPayload>

return table.freeze(remoteSignals)