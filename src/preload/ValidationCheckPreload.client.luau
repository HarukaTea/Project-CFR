
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer


--// Runtime check, it's crazy that it happens
if RunService:IsServer() then
    plr:Kick("This server is invalid. Rejoin can fix it.")
    return
end


Debris:AddItem(script, 15)