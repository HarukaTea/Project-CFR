

repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")



local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local CADimension = require(SSS.HarukaServer.Shared.CADimension)



local worldIdWhiteList = { "InitusWorld" }
local worldId = workspace:GetAttribute("WorldId") or "Unknown"

if not table.find(worldIdWhiteList, worldId) then return end

CADimension:Init()
CADimension:AddToDimension()



local serverSymbolContainer = workspace.MapComponents.GlobalServers :: Folder

HarukaLib.Clock(15, function()
    local currentWorldServers = CADimension:GetWorlds()

    serverSymbolContainer:ClearAllChildren()

    for _, server: CADimension.ServerInfo in currentWorldServers do
        if not server.JobId then continue end
        if #server.PlayerUserIds <= 0 then continue end


        local symbol = Instance.new("IntValue")
        symbol.Name = server.JobId
        symbol.Value = #server.PlayerUserIds

        symbol:SetAttribute("CityLocation", server.CityLocation)
        symbol:SetAttribute("ServerLocation", server.ServerLocation)
        symbol:SetAttribute("WorldId", server.WorldId)
        symbol:SetAttribute("ServerName", server.ServerName)

        symbol.Parent = serverSymbolContainer
    end

end, true)