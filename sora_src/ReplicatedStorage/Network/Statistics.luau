local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local LyncTyping = require(Typing.Lync)

local BitsEnum = require(Enums.Bits)

local Lync = require(ReplicatedStorage.Packages.Lync)

local remoteSignals = {}

remoteSignals.statisticsUpdated = Lync.packet("statisticsUpdated", Lync.deltaMap(Lync.string, BitsEnum.f64Lync)) :: LyncTyping.Packet<{ [string]: number }>

return table.freeze(remoteSignals)