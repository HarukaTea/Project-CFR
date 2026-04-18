local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = require(ReplicatedStorage.Constants.Typing.Lync)
local Lync = require(ReplicatedStorage.Packages.Lync) :: Typing.LyncLib

local MAX_EXP: number = 10^10
local PRECISION: number = 0.1

local playerDataNetwork = {}

playerDataNetwork.classUpdated = Lync.packet("classUpdated", Lync.deltaStruct({
    expPoints = Lync.int(0, MAX_EXP),
    perks = Lync.deltaMap(Lync.string, Lync.deltaStruct({
        quantity = Lync.int(0, 20),
    })),
}))

-- Let's not show archived slots
playerDataNetwork.slotLoaded = Lync.packet("slotLoaded", Lync.deltaStruct({
    expPoints = Lync.int(0, MAX_EXP),
    stats = Lync.deltaMap(Lync.string, Lync.int(0, 1000)),
    creationDate = Lync.float(0, 2^64, PRECISION),
    playTime = Lync.float(0, 2^32, PRECISION),
}))

return table.freeze(playerDataNetwork)