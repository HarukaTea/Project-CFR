
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


if RunService:IsClient() then
    warn("Invalid runtime environment")

    workspace:SetAttribute("Haruka_ServerLocked", true)


    for _, plr: Player in Players:GetPlayers() do
        plr:Kick("This server is shutting down, please do server hopping or wait for a while.")
    end
end


workspace:SetAttribute("Haruka_ServerValidated", true)