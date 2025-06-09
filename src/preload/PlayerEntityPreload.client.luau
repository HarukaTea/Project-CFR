
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


if not game.Loaded then
    game.Loaded:Wait()
end

local wait = task.wait



repeat wait() until ReplicatedStorage:WaitForChild("HarukaShared", 999)
repeat wait() until ReplicatedStorage.HarukaShared:WaitForChild("Shared", 999)
repeat wait() until ReplicatedStorage.HarukaShared.Shared:WaitForChild("Promise", 999)
repeat wait() until ReplicatedStorage.HarukaShared:WaitForChild("UIAtlas", 999)
repeat wait() until ReplicatedStorage.HarukaShared.UIAtlas:WaitForChild("UI", 999)
repeat wait() until ReplicatedStorage.HarukaShared.UIAtlas.UI:WaitForChild("Fantasy_preload", 999)
repeat wait() until ReplicatedStorage.HarukaShared.UIAtlas.UI:WaitForChild("ConfirmPrompt_preload", 999)
repeat wait() until ReplicatedStorage.HarukaShared.UIAtlas.UI:WaitForChild("ExplorerHints_preload", 999)
repeat wait() until ReplicatedStorage.HarukaShared.UIAtlas.UI:WaitForChild("CircularFadeTex_preload", 999)
repeat wait() until workspace:GetAttribute("Haruka_ServerInited")


repeat wait() until workspace:WaitForChild("MapComponents", 999)
repeat wait() until workspace.MapComponents:WaitForChild("Titlescreen", 999)
repeat wait() until workspace.MapComponents.Titlescreen:WaitForChild("CameraLocator", 999)

local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)


local player = Players.LocalPlayer


local PreloadPlayerLib = {}


function PreloadPlayerLib:Init()
    self:_InitUI()
end


function PreloadPlayerLib:_InitUI()
    for _, module in ReplicatedStorage.HarukaShared.UIAtlas.UI:GetChildren() do
        if string.find(module.Name, ".spec") then warn(module.Name) continue end
        if not string.find(module.Name, "_preload") then continue end

        Promise.try(require(module), player):catch(function(err)
            warn(tostring(err))
        end)
    end
end


PreloadPlayerLib:Init()
