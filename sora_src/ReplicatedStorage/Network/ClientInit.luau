-- this is for client -> server only
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LyncTyping = require(ReplicatedStorage.Constants.Typing.Lync)
local Lync = require(ReplicatedStorage.Packages.Lync) :: LyncTyping.LyncLib

local remoteSignals = {}

--- Lets the server know that the client has loaded properly.
remoteSignals.clientLoaded = Lync.packet("clientLoaded", Lync.nothing) :: LyncTyping.Packet<nil>

return table.freeze(remoteSignals)