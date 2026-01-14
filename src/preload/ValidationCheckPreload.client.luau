
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RepS = game:GetService("ReplicatedStorage")

local plr = Players.LocalPlayer

local wait = task.wait

--// Runtime check, it's crazy that it happens
if RunService:IsServer() then
    plr:Kick("This server is invalid. Rejoin can fix it.")
    return
end

--- do i have a more sanitized way to do this?
--- replicatedFirst service sometimes will load faster than client
--- so we need to wait for it to load before we can validate the client

repeat wait() until RepS:WaitForChild("HarukaShared", 999)
repeat wait() until RepS:WaitForChild("Packages", 999)

repeat wait() until RepS.HarukaShared:WaitForChild("Shared", 999)
repeat wait() until RepS.HarukaShared:WaitForChild("UIAtlas", 999)
repeat wait() until RepS.HarukaShared:WaitForChild("Library", 999)

repeat wait() until RepS.HarukaShared.Library:WaitForChild("ClientLib", 999)
repeat wait() until RepS.HarukaShared.Library:WaitForChild("AssetBook", 999)
repeat wait() until RepS.HarukaShared.Library:WaitForChild("Bindables", 999)

repeat wait() until RepS.HarukaShared.UIAtlas:WaitForChild("Components", 999)
repeat wait() until RepS.HarukaShared.UIAtlas:WaitForChild("HarukaComponents", 999)
repeat wait() until RepS.HarukaShared.UIAtlas:WaitForChild("FusionComponents", 999)
repeat wait() until RepS.HarukaShared.UIAtlas:WaitForChild("UI", 999)

repeat wait() until RepS.HarukaShared.UIAtlas.UI:WaitForChild("Fantasy_preload", 999)
repeat wait() until RepS.HarukaShared.UIAtlas.UI:WaitForChild("ConfirmPrompt_preload", 999)
repeat wait() until RepS.HarukaShared.UIAtlas.UI:WaitForChild("ExplorerHints_preload", 999)
repeat wait() until RepS.HarukaShared.UIAtlas.UI:WaitForChild("CircularFadeTex_preload", 999)

repeat wait() until RepS.HarukaShared.UIAtlas.Components:WaitForChild("LoadView", 999)

repeat wait() until RepS.HarukaShared.Shared:WaitForChild("Fusion", 999)
repeat wait() until RepS.HarukaShared.Shared:WaitForChild("HarukaLib", 999)
repeat wait() until RepS.HarukaShared.Shared:WaitForChild("Promise", 999)

repeat wait() until RepS.HarukaShared:WaitForChild("Library", 999)

repeat wait() until RepS.Packages:WaitForChild("UIAtlas", 999)
repeat wait() until RepS.Packages:WaitForChild("Unloads", 999)
repeat wait() until RepS.Packages.Unloads:WaitForChild("TeleportUI", 999)

repeat wait() until workspace:WaitForChild("MapComponents", 999)

workspace:SetAttribute("Haruka_ClientValidated", true)

Debris:AddItem(script, 15)