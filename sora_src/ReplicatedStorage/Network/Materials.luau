local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local LyncTyping = require(Typing.Lync)

local BitsEnum = require(Enums.Bits)

local Lync = require(ReplicatedStorage.Packages.Lync)

export type NewMaterialsQuantityPayload = {
    [string]: number
}

local remoteSignals = {}

--- Sends the full materials map on first fire (slot load), then only changed entries on subsequent fires.
remoteSignals.materialsUpdated = Lync.packet("materialsUpdated", Lync.deltaMap(Lync.string, BitsEnum.i32Lync)) :: LyncTyping.Packet<NewMaterialsQuantityPayload>

remoteSignals.newMaterialObtained = Lync.packet("newMaterialObtained", Lync.string) :: LyncTyping.Packet<string>

return table.freeze(remoteSignals)