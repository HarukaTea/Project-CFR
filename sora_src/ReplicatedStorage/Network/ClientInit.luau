-- this is for client -> server only
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lync = require(ReplicatedStorage.Packages.Lync)

local remoteSignals = {}

--- Lets the server know that the client has loaded properly.
remoteSignals.clientLoaded = Lync.packet("clientLoaded", Lync.nothing)

return table.freeze(remoteSignals)