--[[
    This is a networking module meant for the server to send information to the client.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = require(ReplicatedStorage.Constants.Typing.Lync)
local Lync = require(ReplicatedStorage.Packages.Lync) :: Typing.LyncLib

local debuggingNetwork = {}

type ErrorPayload = {
    header: string,
    errorMessage: string,
    info: string?,
}

type WarningPayload = {
    header: string,
    warnMessage: string,
    info: string,
}

type InfoPayload = {
    header: string,
    message: string,
}

debuggingNetwork.errorOccurred = Lync.packet("errorOccurred", Lync.deltaStruct({
    header = Lync.string,
    errorMessage = Lync.string,
    info = Lync.optional(Lync.string)
})) :: Typing.Packet<ErrorPayload>

debuggingNetwork.infoOccurred = Lync.packet("infoOccurred", Lync.deltaStruct({
    header = Lync.string,
    message = Lync.string,
})) :: Typing.Packet<InfoPayload>

return debuggingNetwork