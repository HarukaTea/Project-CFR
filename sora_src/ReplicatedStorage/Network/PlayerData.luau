local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing

local LyncTyping = require(Typing.Lync)
local Lync = require(ReplicatedStorage.Packages.Lync) :: LyncTyping.LyncLib

local PlayerDataTyping = require(Typing.PlayerData)

export type ClassUpdatedPayload = {
    className: string,
    data: PlayerDataTyping.ClassData,
}

export type InventoryUpdatedPayload = {
    itemType: PlayerDataTyping.InventoryType,
    items: { [string]: { PlayerDataTyping.ItemData } },
}

local remoteSignals = {}

--- Client requests data from the server
remoteSignals.requestData = Lync.packet("requestData", Lync.nothing) :: LyncTyping.Packet<nil>

--- Client chooses a save slot to use.
remoteSignals.selectSaveSlot = Lync.packet("selectSaveSlot", Lync.int(1, 3)) :: LyncTyping.Packet<number>

--- Sends player data to the client.
--- `Internal` will not exist.
remoteSignals.playerDataSent = Lync.packet("playerDataSent", PlayerDataTyping.schemaLync) :: LyncTyping.Packet<PlayerDataTyping.PlayerData>

remoteSignals.classUpdated = Lync.packet("classUpdated", Lync.struct({
    className = Lync.string,
    data = PlayerDataTyping.classDataLync,
})) :: LyncTyping.Packet<ClassUpdatedPayload>

remoteSignals.inventoryUpdated = Lync.packet("inventoryUpdated", Lync.struct({
    itemType = Lync.enum("weapons", "accessories", "armors"),
    items = Lync.map(Lync.string, Lync.deltaArray(PlayerDataTyping.itemDataLync)),
})) :: LyncTyping.Packet<InventoryUpdatedPayload>

return table.freeze(remoteSignals)