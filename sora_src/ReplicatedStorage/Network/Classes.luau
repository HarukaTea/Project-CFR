local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing

local LyncTyping = require(Typing.Lync)
local PlayerDataTyping = require(Typing.PlayerData)
local ClassTyping = require(Typing.PlayerData.Class)

local Lync = require(ReplicatedStorage.Packages.Lync)

export type ClassesUpdatedPayload = {
    [string]: PlayerDataTyping.ClassData,
}

export type PerksPayload = {
    className: string,
    perks: { [string]: number },
}

local remoteSignals = {}

remoteSignals.classesUpdated = Lync.packet("classesUpdated", Lync.deltaMap(Lync.string, ClassTyping.playerClassDataLync)) :: LyncTyping.Packet<ClassesUpdatedPayload>

remoteSignals.classUnlocked = Lync.packet("classUnlocked", Lync.string) :: LyncTyping.Packet<string>

return table.freeze(remoteSignals)