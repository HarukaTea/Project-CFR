local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing

local LyncTyping = require(Typing.Lync)

local Lync = require(ReplicatedStorage.Packages.Lync)


local remoteSignals = {}

--- Client requests to equip a cosmetic item.
remoteSignals.equipCosmeticItem = Lync.packet("equipCosmeticItem", Lync.string) :: LyncTyping.Packet<string>

--- Client request to unequip a cosmetic item.
remoteSignals.unequipCosmeticItem = Lync.packet("unequipCosmeticItem", Lync.string) :: LyncTyping.Packet<string>

--- Server updates the client about the current cosmetic items
remoteSignals.cosmeticItemsUpdated = Lync.packet("cosmeticItemsUpdated", Lync.map(Lync.string, Lync.bool)) :: LyncTyping.Packet<{ [string]: boolean }>

return table.freeze(remoteSignals)