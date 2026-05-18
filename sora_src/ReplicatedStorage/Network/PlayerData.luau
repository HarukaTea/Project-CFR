local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing

local LyncTyping = require(Typing.Lync)
local SaveSlotsTyping = require(Typing.SaveSlots)

local Lync = require(ReplicatedStorage.Packages.Lync)

export type MaxSaveSlotPayload = LyncTyping.Packet<number>

export type RenameSaveSlotPayload = {
    index: number,
    newName: string,
}

local maxSaveSlotLync = SaveSlotsTyping.maxSaveSlotsLync

local remoteSignals = {}

--- Client requests preview data from the server (shown on save slot selection screen).
remoteSignals.requestPreviewData = Lync.packet("requestPreviewData", Lync.nothing) :: LyncTyping.Packet<nil>

--- Server sends an event that the player has their data reconciled.
remoteSignals.dataReconciled = Lync.packet("dataReconciled", Lync.nothing) :: LyncTyping.Packet<nil>

--- Server sends an event that the player's data has been reset.
remoteSignals.dataReset = Lync.packet("dataReset", Lync.nothing) :: LyncTyping.Packet<nil>

--- Client chooses which save slot to load.
remoteSignals.selectActiveSaveSlot = Lync.packet("selectActiveSaveSlot", maxSaveSlotLync) :: MaxSaveSlotPayload

--- Client chooses to archive a save slot index.
remoteSignals.archiveSaveSlot = Lync.packet("archiveSaveSlot", maxSaveSlotLync) :: MaxSaveSlotPayload

--- Client chooses to rename a save slot.
remoteSignals.renameSaveSlot = Lync.packet("renameSaveSlot", Lync.struct({
    index = maxSaveSlotLync,
    newName = Lync.string,
})) :: LyncTyping.Packet<RenameSaveSlotPayload>

--- Server alerts the client that the save slot has been successfully selected.
remoteSignals.saveSlotSelected = Lync.packet("saveSlotSelected", maxSaveSlotLync) :: LyncTyping.Packet<number>

--- Server alerts the client that a new save slot was created.
remoteSignals.saveSlotCreated = Lync.packet("saveSlotCreated", maxSaveSlotLync) :: MaxSaveSlotPayload

--- Server alerts the client that a save slot was archived.
remoteSignals.saveSlotArchived = Lync.packet("saveSlotArchived", maxSaveSlotLync) :: MaxSaveSlotPayload

return table.freeze(remoteSignals)