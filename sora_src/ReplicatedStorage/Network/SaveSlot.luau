local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local LyncTyping = require(Typing.Lync)
local PlayerDataTyping = require(Typing.PlayerData)

local SaveSlotsEnum = require(Enums.SaveSlots)
local BitsEnums = require(Enums.Bits)

local Lync = require(ReplicatedStorage.Packages.Lync)

export type SaveSlotLoadedPayload = {
    index: number,
    data: PlayerDataTyping.SaveSlot,
}

export type RenameSaveSlotPayload = {
    index: number,
    newName: string,
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

export type MaxSaveSlotPayload = LyncTyping.Packet<number>

local maxSaveSlotLync = SaveSlotsEnum.maxSaveSlotsLync

local remoteSignals = {}

remoteSignals.selectActiveSaveSlot = Lync.packet("selectActiveSaveSlot", maxSaveSlotLync) :: MaxSaveSlotPayload

--- Client chooses to archive a save slot index.
remoteSignals.archiveSaveSlot = Lync.packet("archiveSaveSlot", maxSaveSlotLync) :: MaxSaveSlotPayload  

--- Client chooses to rename a save slot index.
remoteSignals.renameSaveSlot = Lync.packet("renameSaveSlot", Lync.struct({
    index = maxSaveSlotLync,
    newName = Lync.string,
})) :: LyncTyping.Packet<RenameSaveSlotPayload>

--- Server alerts the client that the save slot has been successfully selected.
remoteSignals.saveSlotSelected = Lync.packet("saveSlotSelected", maxSaveSlotLync) :: LyncTyping.Packet<number>

remoteSignals.saveSlotCreated = Lync.packet("saveSlotCreated", maxSaveSlotLync) :: MaxSaveSlotPayload

remoteSignals.saveSlotArchived = Lync.packet("saveSlotArchived", maxSaveSlotLync) :: MaxSaveSlotPayload

remoteSignals.playerExpUpdated = Lync.packet("playerExpUpdated", Lync.struct({
    index = Lync.int(1, 3),
    oldExp = BitsEnums.f64Lync,
    newExp = BitsEnums.f64Lync,
})) :: LyncTyping.Packet<PlayerExpUpdatedPayload>

remoteSignals.statPointsUpdated = Lync.packet("statPointsUpdated", Lync.deltaStruct({
    str = BitsEnums.u16Lync,
    agi = BitsEnums.u16Lync,
    int = BitsEnums.u16Lync,
    vit = BitsEnums.u16Lync,
    dex = BitsEnums.u16Lync,
})) :: LyncTyping.Packet<StatPointsUpdatedPayload>

return table.freeze(remoteSignals)