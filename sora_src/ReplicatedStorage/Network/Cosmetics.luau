local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lync = require(ReplicatedStorage.Packages.Lync)

local remoteSignals = {}

remoteSignals.cosmeticItemsLoaded = Lync.packet("cosmeticItemsLoaded", Lync.array(Lync.string))

--- Client requests to equip a cosmetic item.
remoteSignals.equipCosmeticItem = Lync.packet("equipCosmeticItem", Lync.string)

--- Client request to unequip a cosmetic item.
remoteSignals.unequipCosmeticItem = Lync.packet("unequipCosmeticItem", Lync.string)

--- Server announces that the player has successfully equipped the item.
remoteSignals.cosmeticItemEquipped = Lync.packet("cosmeticItemEquipped", Lync.string)

--- Server announces that the player has successfully unequipped the item.
remoteSignals.cosmeticItemUnequipped = Lync.packet("cosmeticItemUnequipped", Lync.string)

--- Server announces that the player has obtained a new cosmetic item.
remoteSignals.cosmeticItemObtained = Lync.packet("cosmeticItemObtained", Lync.string)

return table.freeze(remoteSignals)