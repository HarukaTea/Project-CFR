local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = ReplicatedStorage.Constants.Enums

local SaveSlotsEnums = require(Enums.SaveSlots)
local Lync = require(ReplicatedStorage.Packages.Lync)

local remoteSignals = {}

--- Client requests data from the server.
remoteSignals.requestData = Lync.packet("requestData", Lync.nothing)

--- Server alerts all sub-components that a save slot has been selected and is ready.
remoteSignals.saveSlotSelected = Lync.packet("saveSlotSelected", Lync.int(1, SaveSlotsEnums.maxSaveSlots))

return table.freeze(remoteSignals)