local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local PlayerDataTyping = require(Typing.PlayerData)

local BitsEnums = require(Enums.Bits)
local PerksEnums = require(Enums.Perks)

local Lync = require(ReplicatedStorage.Packages.Lync)

export type ClassesLoadedPayload = {
    [string]: PlayerDataTyping.ClassData,
}

export type ClassUpdatedPayload = {
    className: string,
    data: PlayerDataTyping.ClassData,
}

export type PerksPayload = {
    className: string,
    perks: { [string]: number },
}

export type ClassExpUpdatedPayload = {
    className: string,
    oldExp: number,
    newExp: number,
}

local perksLync = Lync.struct({
    className = Lync.string,
    perks = Lync.map(Lync.string, Lync.int(0, PerksEnums.maxPerkValue)),
})

local remoteSignals = {}

remoteSignals.setPerkPoints = Lync.packet("addPerkPoints", perksLync)

remoteSignals.classesLoaded = Lync.packet("classesLoaded", Lync.map(Lync.string, PlayerDataTyping.classDataLync))

remoteSignals.classUpdated = Lync.packet("classUpdated", Lync.struct({
    className = Lync.string,
    data = PlayerDataTyping.classDataLync,
}))

remoteSignals.classUnlocked = Lync.packet("classUnlocked", Lync.string)

remoteSignals.classExpUpdated = Lync.packet("classExpUpdated", Lync.struct({
    className = Lync.string,
    oldExp = BitsEnums.uf64Lync,
    newExp = BitsEnums.uf64Lync,
}))

remoteSignals.perksUpdated = Lync.packet("perksUpdated", perksLync)

return table.freeze(remoteSignals)