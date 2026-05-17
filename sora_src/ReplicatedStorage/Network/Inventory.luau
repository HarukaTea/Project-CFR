local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local LyncTyping = require(Typing.Lync)
local PlayerDataTyping = require(Typing.PlayerData)

local BitsEnums = require(Enums.Bits)

local Lync = require(ReplicatedStorage.Packages.Lync)

export type ItemsUpdatedPayload = {

}

local remoteSignals = {}

remoteSignals.itemsUpdated = Lync.packet("itemsUpdated", PlayerDataTyping.inventoryLync) :: LyncTyping.Packet<ItemsUpdatedPayload>

remoteSignals.equippedItemsUpdated = Lync.packet("equippedItemsUpdated", Lync.deltaArray(BitsEnums.u32Lync))

return table.freeze(remoteSignals)