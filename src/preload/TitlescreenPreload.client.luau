--!nocheck

local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local SG = game:GetService("StarterGui")
local RepS = game:GetService("ReplicatedStorage")

local plr = Players.LocalPlayer

local wait = task.wait


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
    plr:Kick("This server is invalid. Rejoin can fix it.")
    return
end


--// Core ui init
do
    SG:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    SG:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
end


local function _createTempHolderGui()
    local holderGui = Instance.new("ScreenGui")
    holderGui.Name = "Temp_LoadScreen"
    holderGui.ScreenInsets = Enum.ScreenInsets.None
    holderGui.ClipToDeviceSafeArea = false
    holderGui.DisplayOrder = 998
    holderGui.Parent = plr.PlayerGui

    local frame = Instance.new("Frame")
    frame.Name = "Full"
    frame.Size = UDim2.fromScale(1, 1)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 37)
    frame.BackgroundTransparency = 0
    frame.ZIndex = 0
    frame.Parent = holderGui

    local bottom = Instance.new("Frame")
    bottom.Name = "Bottom"
    bottom.Size = UDim2.fromScale(1, 0.1)
    bottom.Position = UDim2.fromScale(0, 1)
    bottom.AnchorPoint = Vector2.new(0, 1)
    bottom.BackgroundTransparency = 1
    bottom.ZIndex = 1

    local uiAspectRatio = Instance.new("UIAspectRatioConstraint")
    uiAspectRatio.AspectRatio = 25.627
    uiAspectRatio.Parent = bottom


    local text = Instance.new("TextLabel")
    text.Name = "LoadingText"
    text.Position = UDim2.fromScale(0, -0.3)
    text.Size = UDim2.fromScale(1, 0.5)
    text.Text = "Initializing Sky Galleons..."
    text.BackgroundTransparency = 1
    text.FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold)
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextScaled = true
    text.Parent = bottom

    bottom.Parent = holderGui

    return holderGui
end


--// Load screen
do
    local holderGui = _createTempHolderGui()

    if not game.Loaded then
        game.Loaded:Wait()
    end

    repeat task.wait() until RepS:WaitForChild("HarukaShared", 999)
    repeat task.wait() until RepS.HarukaShared:WaitForChild("Shared", 999)
    repeat task.wait() until RepS.HarukaShared:WaitForChild("UIAtlas", 999)
    repeat task.wait() until RepS.HarukaShared.UIAtlas:WaitForChild("Components", 999)
    repeat task.wait() until RepS.HarukaShared.UIAtlas.Components:WaitForChild("LoadView", 999)
    repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


    --// Load view
    local Fusion = require(RepS.HarukaShared.Shared.Fusion)
    local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

    local LoadView = require(RepS.HarukaShared.UIAtlas.Components.LoadView)

    local scope = Fusion.scoped()
    local UI: ScreenGui = nil

    local LoadingTextVal = Fusion.Value(scope, "Sailing to Initus Bay...")
    local isAlreadyLoaded = false

    UI = LoadView(scope, {
        LoadingText = LoadingTextVal
    })
    HarukaLib:UITween(UI, "In", {
        TweenCallback = function()
            Debris:AddItem(holderGui, 1)
        end
    })

    task.delay(8, function()
        if isAlreadyLoaded then return end

        LoadingTextVal:set("Datastore is taking longer than expected...")
    end)
    task.delay(23, function()
        if isAlreadyLoaded then return end

        LoadingTextVal:set("Datastore is taking too long to load...")
    end)
    task.delay(33, function()
        if isAlreadyLoaded then return end

        LoadingTextVal:set("Datastore loaded time out!")

        plr:Kick("We're sorry, but datastore took too long to load. Maybe try again later?")
    end)


    repeat wait() until plr:GetAttribute("_PlayerProfileInited")

    isAlreadyLoaded = true


    --// Titlescreen
    local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)

     --// FIXME: First demo version confirm prompt
    wait(2)
    local result = Components:CreateConfirmPrompt(scope, {
        Hint = "Current version is <red>unfinished</font>, and may contain unwanted bugs and glitches. Do you still wish to continue?",
        ConfirmText = "YES",
        CancelText = "NO",

        ConfirmUniqueId = "ConfirmDemoVersion"
    }):Wait()

    if result == "NO" then
        plr:Kick("Thank you for your interest in our game. We hope to see you again soon!")
        return
    end


    if HarukaLib:GetDevice() == "Mobile" then
        wait(1.5)
        local result = Components:CreateConfirmPrompt(scope, {
            Hint = "When using <yellow>mobile devices</font>, you may encounter <red>performance issues</font>. Do you still wish to continue?",
            ConfirmText = "YES",
            CancelText = "NO",

            ConfirmUniqueId = "ConfirmMobileVersion"
        }):Wait()

        if result == "NO" then
            plr:Kick("Thank you for your interest in our game. We hope to see you again soon!")
            return
        end
    end


    wait(1)
    HarukaLib:UITween(UI, "Out", {
        TweenCallback = function()
            Fusion.doCleanup(scope)
        end
    })
    workspace:SetAttribute("Haruka_CompletedPreload", true)


    --// init ambient
    SoundService.Musics.Titlescreen:Play()

    Lighting:SetAttribute("RainLevel", 6)
    Lighting.Ambient = Color3.fromRGB(122, 122, 122)
    Lighting.Brightness = 10
    Lighting.ColorShift_Bottom = Color3.fromRGB(18, 18, 18)
    Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 68)
    Lighting.OutdoorAmbient = Color3.fromRGB(75, 75, 75)
    Lighting.ClockTime = 0
    Lighting.GeographicLatitude = 255

    local atmosphere = Instance.new("Atmosphere")
    atmosphere.Name = "TitlescreenAtmosphere"
    atmosphere.Color = Color3.fromRGB(116, 125, 140)
    atmosphere.Decay = Color3.fromRGB(87, 96, 111)
    atmosphere.Glare = 0
    atmosphere.Haze = 3
    atmosphere.Density = 0.4
    atmosphere.Parent = Lighting

    if Lighting:FindFirstChildOfClass("Sky") then
        Lighting:FindFirstChildOfClass("Sky"):Destroy()
    end
    RepS.Packages.Unloads._TitlescreenSkybox:Clone().Parent = Lighting

    if workspace.Terrain:FindFirstChildOfClass("Clouds") then
        workspace.Terrain.Clouds.Color = Color3.fromRGB(31, 31, 31)
    end


    repeat wait() until plr.Character
    repeat wait() until plr.Character.PrimaryPart
    repeat wait() until plr.Character:GetAttribute("_CharDataInited")

    pcall(function()
        Lighting.Ambient = Color3.fromRGB(159, 159, 159)
        Lighting.Brightness = 1.599
        Lighting.ColorShift_Bottom = Color3.fromRGB(220, 255, 255)
        Lighting.ColorShift_Top = Color3.fromRGB(220, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(241, 242, 246)
        Lighting.ClockTime = 14
        Lighting.GeographicLatitude = 0

        Lighting:SetAttribute("RainLevel", 0)

        if workspace.Terrain:FindFirstChildOfClass("Clouds") then
            workspace.Terrain.Clouds.Color = Color3.fromRGB(255, 255, 255)
        end

        atmosphere:Destroy()
        Lighting._TitlescreenSkybox:Destroy()

        RepS.Packages.Unloads._WorldSkybox:Clone().Parent = Lighting


        workspace.MapComponents.Titlescreen:Destroy()
    end)

    HarukaLib:CreateTween(SoundService.Musics.Titlescreen, TweenInfo.new(0.5), {
        Volume = 0
    }):Play()

    Debris:AddItem(SoundService.Musics.Titlescreen, 5)
    workspace:SetAttribute("Haruka_GameEntered", true)
end
