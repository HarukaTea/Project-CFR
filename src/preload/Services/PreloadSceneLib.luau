local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")


local wait = task.wait


repeat wait() until ReplicatedStorage.HarukaShared:WaitForChild("Library", 999)
repeat wait() until ReplicatedStorage.HarukaShared.Library:WaitForChild("AssetBook", 999)
repeat wait() until ReplicatedStorage.HarukaShared.Shared:WaitForChild("HarukaLib", 999)
repeat wait() until ReplicatedStorage:WaitForChild("Packages", 999)
repeat wait() until ReplicatedStorage.Packages:WaitForChild("Unloads", 999)
repeat wait() until ReplicatedStorage.Packages.Unloads:WaitForChild("TeleportUI", 999)


local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()


local PreloadSceneLib = {}

function PreloadSceneLib:_LoadPreloadAssets()
    local placeHolderGui = Instance.new("ScreenGui")
    placeHolderGui.Name = "PlaceHolderGui_Preload"
    placeHolderGui.ResetOnSpawn = false
    placeHolderGui.Parent = Players.LocalPlayer.PlayerGui

    local totalAssets = {}

    for _, imageId: string in AssetBook.PreloadAssets.Images do
        local image = Instance.new("ImageLabel")
        image.Name = "ImageForPreload"
        image.Image = imageId
        image.Interactable = false
        image.Visible = true
        image.BackgroundTransparency = 1
        image.Size = UDim2.fromOffset(1, 1)
        image.ImageTransparency = 0
        image.Parent = placeHolderGui

        table.insert(totalAssets, image)
    end

    local now = os.clock()
    ContentProvider:PreloadAsync(totalAssets)

    print(`[PreloadLib] All assets preloaded, spent {string.format("%.2f", os.clock() - now)} seconds`)
end


function PreloadSceneLib:_LoadTeleportEvents()
    TeleportService:SetTeleportGui(ReplicatedStorage.Packages.Unloads.TeleportUI)
end



function PreloadSceneLib:_LoadScreenMouseFollower()
    task.spawn(function()
        if workspace:GetAttribute("NoRequiresTitlescreen") then return end


        repeat wait() until workspace:WaitForChild("MapComponents", 999)
        repeat wait() until workspace.MapComponents:WaitForChild("Titlescreen", 999)
        repeat wait() until workspace.MapComponents.Titlescreen:WaitForChild("CameraLocator", 999)


        local locator = workspace.MapComponents.Titlescreen.CameraLocator :: BasePart

        local camera = workspace.CurrentCamera
        local XFloat, YFloat = 0, 0
        local maxXRotation, maxYRotation = 5, 5
        local rad, clock, noise, random = math.rad, os.clock, math.noise, math.random
        local xSeed, ySeed, zSeed = random(10 ^ 3, 10 ^ 4), random(10 ^ 3, 10 ^ 4), random(10 ^ 3, 10 ^ 4)

        camera.CameraType = Enum.CameraType.Scriptable
        camera.CameraSubject = locator
        camera.CFrame = locator.CFrame


        repeat task.wait() until workspace:GetAttribute("Haruka_CompletedPreload")

        local mouse = Players.LocalPlayer:GetMouse()
        Add(mouse.Move:Connect(function()
            XFloat = -0.5 + mouse.X / camera.ViewportSize.X
            YFloat = -0.5 + mouse.Y / camera.ViewportSize.Y
        end))
        Add(RunService.RenderStepped:Connect(function()
            local x = noise(xSeed, clock() % 1000 * 0.5)
            local y = noise(ySeed, clock() % 1000 * 0.5)
            local z = noise(zSeed, clock() % 1000 * 0.5)

            local dynamicMouseCF = CFrame.fromOrientation(
                rad(maxYRotation * -YFloat)
                ,rad(maxXRotation * -XFloat)
                ,0
            )
            camera.CFrame = locator.CFrame * dynamicMouseCF.Rotation * CFrame.Angles(rad(x),rad(y),rad(z)).Rotation
        end))
    end)
end



function PreloadSceneLib:Destroy()
    Empty()

    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = Players.LocalPlayer.Character.Humanoid
end

return PreloadSceneLib
