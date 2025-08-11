--!nocheck

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


if not game.Loaded then
    game.Loaded:Wait()
end

repeat task.wait() until ReplicatedStorage:WaitForChild("HarukaShared", 999)
repeat task.wait() until ReplicatedStorage.HarukaShared:WaitForChild("Shared", 999)
repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")

local PreloadSceneLib = require(script.Parent:WaitForChild("Services", 999):WaitForChild("PreloadSceneLib", 999))
PreloadSceneLib._LoadPreloadAssets()
PreloadSceneLib._LoadTeleportEvents()
PreloadSceneLib._LoadScreenMouseFollower()

repeat task.wait() until workspace:GetAttribute("Haruka_TitlescreenDestroying")

PreloadSceneLib.Cleanup()



Debris:AddItem(script, 15)
