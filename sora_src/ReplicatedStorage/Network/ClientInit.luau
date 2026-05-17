-- this is for client -> server only
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local LyncTyping = require(Typing.Lync)

local SaveSlotsEnum = require(Enums.SaveSlots)

local Lync = require(ReplicatedStorage.Packages.Lync)

--- From 1 to 3 index, based on SaveSlotsEnum.maxSaveSlots.
local maxSaveSlotLync = Lync.int(1, SaveSlotsEnum.maxSaveSlots)

local remoteSignals = {}

--- Lets the server know that the client has loaded properly.
remoteSignals.clientLoaded = Lync.packet("clientLoaded", Lync.nothing) :: LyncTyping.Packet<nil>

--- Client chooses a save slot to use.
remoteSignals.selectSaveSlot = Lync.packet("selectSaveSlot", maxSaveSlotLync) :: LyncTyping.Packet<number>

return table.freeze(remoteSignals)