local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing

local LyncTyping = require(Typing.Lync)

local Lync = require(ReplicatedStorage.Packages.Lync)

local remoteSignals = {}

--- Client requests data from the server.
remoteSignals.requestData = Lync.packet("requestData", Lync.nothing) :: LyncTyping.Packet<nil>

--- Server sends an event that the player has their data reconciled.
remoteSignals.dataReconciled = Lync.packet("dataReconciled", Lync.nothing) :: LyncTyping.Packet<nil>

--- Server sends an event that the player's data has been reset.
remoteSignals.dataReset = Lync.packet("dataReset", Lync.nothing)

return table.freeze(remoteSignals)