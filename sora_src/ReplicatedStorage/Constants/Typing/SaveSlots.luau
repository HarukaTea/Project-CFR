local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = ReplicatedStorage.Constants.Enums

local SaveSlotsEnum = require(Enums.SaveSlots)

local t = require(ReplicatedStorage.Packages.t)
local Lync = require(ReplicatedStorage.Packages.Lync)

local maxSaveSlots = SaveSlotsEnum.maxSaveSlots
local typing = {}

typing.maxSaveSlotsT = t.intersection(t.number, t.numberMin(1), t.numberMax(maxSaveSlots))

typing.maxSaveSlotsLync = Lync.int(1, maxSaveSlots)

return table.freeze(typing)