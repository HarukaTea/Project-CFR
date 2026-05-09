local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local PlayerDataTyping = require(Typing.PlayerData)

local SaveSlotsEnums = require(Enums.SaveSlots)
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

--- From 1 to 3 index, based on SaveSlotsEnums.maxSaveSlots.
local maxSaveSlotLync = Lync.int(1, SaveSlotsEnums.maxSaveSlots)

local remoteSignals = {}

--- Client chooses a save slot to use.
remoteSignals.selectSaveSlot = Lync.packet("selectSaveSlot", maxSaveSlotLync)

--- Client chooses to archive a save slot index.
remoteSignals.archiveSaveSlot = Lync.packet("archiveSaveSlot", maxSaveSlotLync)

--- Client chooses to rename a save slot index.
remoteSignals.renameSaveSlot = Lync.packet("renameSaveSlot", Lync.struct({
    index = maxSaveSlotLync,
    newName = Lync.string,
}))

--- Server announces the player's save slot that has been loaded.
remoteSignals.saveSlotLoaded = Lync.packet("saveSlotLoaded", Lync.struct({
    index = maxSaveSlotLync,
    data = PlayerDataTyping.saveSlotLync,
}))

remoteSignals.saveSlotCreated = Lync.packet("saveSlotCreated", maxSaveSlotLync)

remoteSignals.saveSlotArchived = Lync.packet("saveSlotArchived", maxSaveSlotLync)

remoteSignals.playerExpUpdated = Lync.packet("playerExpUpdated", Lync.struct({
    index = Lync.int(1, 3),
    oldExp = BitsEnums.f64Lync,
    newExp = BitsEnums.f64Lync,
}))

return table.freeze(remoteSignals)