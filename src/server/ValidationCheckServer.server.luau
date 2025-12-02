
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

if RunService:IsClient() then
    warn("Invalid runtime environment")

    workspace:SetAttribute("Haruka_ServerLocked", true)

    for _, plr: Player in Players:GetPlayers() do
        plr:Kick("This server is shutting down, please do server hopping or wait for a while.")
    end
    return
end


if Players.CharacterAutoLoads then
    error("[ERROR] You forgot to disable CharacterAutoLoads!")
    return
end
if not workspace:FindFirstChild("Maps") then
    error("[ERROR] You forgot to create a 'Maps' folder!")
    return
end
if not workspace:FindFirstChild("MapComponents") then
    error("[ERROR] You forgot to create a 'MapComponents' folder!")
    return
end
if not workspace:FindFirstChild("Enemies") then
    error("[ERROR] You forgot to create a 'Enemies' folder!")
    return
end


workspace:SetAttribute("Haruka_ServerValidated", true)