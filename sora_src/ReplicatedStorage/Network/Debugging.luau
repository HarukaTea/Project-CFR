--[[
    This is a networking module meant for the server to send information to the client.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lync = require(ReplicatedStorage.Packages.Lync)

local remoteSignals = {}

export type LogPayload = {
    level: "error" | "warning" | "info",
    header: string,
    message: string,
    sender: string, -- Name of the server script
    footer: string?, -- Additional info
}

remoteSignals.logOccurred = Lync.packet("logOccurred", Lync.deltaStruct({
    level = Lync.enum("error", "warning", "info"),
    header = Lync.string,
    message = Lync.string,
    sender = Lync.string,
    footer = Lync.optional(Lync.string),
}))

return table.freeze(remoteSignals)