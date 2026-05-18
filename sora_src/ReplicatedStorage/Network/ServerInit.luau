-- Server to client only.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local LyncTyping = require(Typing.Lync)

local SaveSlotsTyping = require(Typing.SaveSlots)

local Lync = require(ReplicatedStorage.Packages.Lync)

local remoteSignals = {}

--- Sends a signal to the player when their data is ready.
remoteSignals.dataReady = Lync.packet("dataReady", SaveSlotsTyping.maxSaveSlotsLync) :: LyncTyping.Packet<number>

return table.freeze(remoteSignals)