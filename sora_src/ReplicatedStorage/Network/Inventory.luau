local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local PlayerDataTyping = require(Typing.PlayerData)

local BitsEnums = require(Enums.Bits)
local SaveSlotsEnum = require(Enums.SaveSlots)

local Lync = require(ReplicatedStorage.Packages.Lync)

export type ItemsLoadedPayload = {
    items: { [string]: { PlayerDataTyping.ItemData } },
}

local remoteSignals = {}

remoteSignals.itemsLoaded = Lync.packet("itemsLoaded", Lync.struct({
    index = SaveSlotsEnum.maxSaveSlotsLync,
    items = Lync.map(Lync.string, Lync.array(PlayerDataTyping.itemDataLync)),
}))

remoteSignals.itemAdded = Lync.packet("itemAdded", BitsEnums.i32Lync)

remoteSignals.itemRemoved = Lync.packet("itemRemoved", BitsEnums.i32Lync)

remoteSignals.itemEquipped = Lync.packet("itemEquipped", BitsEnums.i32Lync)

remoteSignals.itemUnequipped = Lync.packet("itemUnequipped", BitsEnums.i32Lync)

return table.freeze(remoteSignals)