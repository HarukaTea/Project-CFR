local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing

local LyncTyping = require(Typing.Lync)

local Lync = require(ReplicatedStorage.Packages.Lync) :: LyncTyping.LyncLib

local enums = {}

enums.maxSaveSlots = 3

enums.maxSaveSlotsLync = Lync.int(1, enums.maxSaveSlots)

return table.freeze(enums)