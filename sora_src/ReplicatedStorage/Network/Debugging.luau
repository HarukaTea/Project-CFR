--[[
    This is a networking module meant for the server to send information to the client.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = require(ReplicatedStorage.Constants.Typing.Lync)
local Lync = require(ReplicatedStorage.Packages.Lync) :: Typing.LyncLib

local debuggingNetwork = {}

type LogPayload = {
    level: "error" | "warning" | "info",
    header: string,
    message: string,
    sender: string, -- Name of the server script
    info: string?, -- Additional info
}

debuggingNetwork.logOccurred = Lync.packet("logOccurred", Lync.deltaStruct({
    level = Lync.enum("error", "warning", "info"),
    header = Lync.string,
    message = Lync.string,
    sender = Lync.string,
    info = Lync.optional(Lync.string),
})) :: Typing.Packet<LogPayload>

return debuggingNetwork