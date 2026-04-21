local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = require(ReplicatedStorage.Constants.Typing.Lync)
local Lync = require(ReplicatedStorage.Packages.Lync) :: Typing.LyncLib

local MAX_FLOAT: number = 2^64
local PRECISION: number = 0.1

local playerDataNetwork = {}

--- Sends a signal to the player regarding the class data.
playerDataNetwork.classUpdated = Lync.packet("classUpdated", Lync.deltaStruct({
    expPoints = Lync.float(0, MAX_FLOAT, 1),
    perks = Lync.deltaMap(Lync.string, Lync.deltaStruct({
        quantity = Lync.int(0, 20),
    })),
}))

-- Let's not show archived slots
--- Sends the signal to the player if the save slot is selected by player then server loads it.
playerDataNetwork.saveSlotLoaded = Lync.packet("slotLoaded", Lync.deltaStruct({
    expPoints = Lync.float(0, MAX_FLOAT, 1),
    stats = Lync.deltaMap(Lync.string, Lync.int(0, 1000)),
    creationDate = Lync.float(0, MAX_FLOAT, PRECISION),
    playTime = Lync.float(0, MAX_FLOAT, PRECISION),
}))

return table.freeze(playerDataNetwork)