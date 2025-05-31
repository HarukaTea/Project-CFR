--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SG = game:GetService("StarterGui")
local RepS = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local TeleportService = game:GetService("TeleportService")

local plr = Players.LocalPlayer

local wait = task.wait


--// Runtime check, it's crazy that it happens
if RunService:IsServer() then
    plr:Kick("This server is invalid. Rejoin can fix it.")
    return
end
if #Players:GetPlayers() > Players.MaxPlayers then
    plr:Kick("Server is full")
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
    text.Text = string.upper("Initializing Sky Galleons...")
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


    --- wait for replicated storage to load
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end


    repeat wait() until RepS:WaitForChild("HarukaShared", 999)
    repeat wait() until workspace:GetAttribute("Haruka_ServerInited")


    local AssetBook = require(RepS.HarukaShared.Library.AssetBook)

    --// Preload assets
    local PreloadSceneLib = {}

    function PreloadSceneLib:_LoadPreloadAssets()
        local placeHolderGui = Instance.new("ScreenGui")
        placeHolderGui.Name = "PlaceHolderGui_Preload"
        placeHolderGui.ResetOnSpawn = false
        placeHolderGui.Parent = plr.PlayerGui

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
        TeleportService:SetTeleportGui(RepS.Packages.Unloads.TeleportUI)
    end
    PreloadSceneLib:_LoadPreloadAssets()
    PreloadSceneLib:_LoadTeleportEvents()


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


    repeat wait() until Players.LocalPlayer:GetAttribute("_PlayerDataInited")

    isAlreadyLoaded = true


    LoadingTextVal:set("Loading Data...")

    repeat wait() until plr.Character
    repeat wait() until plr.Character.PrimaryPart
    repeat wait() until plr.Character:GetAttribute("_CharDataInited")


    workspace:SetAttribute("Haruka_PreloadCompleted", true)


    --// Do story
    do
        local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

        HarukaLib:UITween(UI, "Out", {
            TweenCallback = function()
                Fusion.doCleanup(scope)
            end
        })

        Debris:AddItem(script, 5)

        if not workspace:GetAttribute("WorldId") then return end
        if workspace:GetAttribute("WorldId") ~= "InitusWorld" then return end

        --// TODO: Add story code here

    end
end
