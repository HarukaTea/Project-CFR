local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lync = require(ReplicatedStorage.Packages.Lync)

local enums = {}

enums.maxSaveSlots = 3

enums.maxSaveSlotsLync = Lync.int(1, enums.maxSaveSlots)

return table.freeze(enums)