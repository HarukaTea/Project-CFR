local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = require(ReplicatedStorage.Constants.Typing.Lync)
local Lync = require(ReplicatedStorage.Packages.Lync) :: Typing.LyncLib


local remoteSignals = {}



return table.freeze(remoteSignals)