
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer


--// Runtime check, it's crazy that it happens
if RunService:IsServer() then
    plr:Kick("This server is invalid. Rejoin can fix it.")
    return
end
if #Players:GetPlayers() > Players.MaxPlayers then
    plr:Kick("Server is full, please rejoin!")
    return
end
if workspace:GetAttribute("Haruka_ServerLocked") then
    plr:Kick("This server is shutting down, please do server hopping or wait for a while.")
    return
end


workspace:SetAttribute("Haruka_ClientValidated", true)


Debris:AddItem(script, 15)