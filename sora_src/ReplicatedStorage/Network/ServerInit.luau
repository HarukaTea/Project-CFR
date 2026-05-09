-- Server to client only.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lync = require(ReplicatedStorage.Packages.Lync)


local remoteSignals = {}

--- Sends a signal to the player when their data is ready.
remoteSignals.dataReady = Lync.packet("dataReady", Lync.nothing)

return table.freeze(remoteSignals)