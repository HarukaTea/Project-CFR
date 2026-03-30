
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SoundService = game:GetService("SoundService")
local SG = game:GetService("StarterGui")
local RepS = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local plr = Players.LocalPlayer

local wait = task.wait

--// Core ui init
do
    ReplicatedFirst:RemoveDefaultLoadingScreen()

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
    uiAspectRatio.AspectRatio = 24
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

    --// replicated first service sometimes wont load
    repeat wait() until workspace:GetAttribute("Haruka_ClientValidated")
    repeat wait() until workspace:GetAttribute("Haruka_ServerInited")

    --// Load view
    local Fusion = require(RepS.HarukaShared.Shared.Fusion)
    local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

    local LoadView = require(RepS.HarukaShared.UIAtlas.Components.LoadView)

    local scope = Fusion.scoped()
    local UI: ScreenGui = nil

    local LoadingTextVal = Fusion.Value(scope, "Sailing to The Initia...")
    local isAlreadyLoaded = false

    UI = LoadView(scope, {
        LoadingText = LoadingTextVal
    })

    HarukaLib:UITransTween(UI, "In", {
        TweenCallback = function()
            Debris:AddItem(holderGui, 1)
        end
    })
    task.spawn(function()
        while not isAlreadyLoaded do
            LoadingTextVal:set("Sailing to The Initia.")
            wait(0.5)
            LoadingTextVal:set("Sailing to The Initia..")
            wait(0.5)
            LoadingTextVal:set("Sailing to The Initia...")
            wait(0.5)
        end
    end)

    local teleportData = TeleportService:GetLocalPlayerTeleportData()
    local shouldSkipTitlescreen = workspace:GetAttribute("NoRequiresTitlescreen")
    local forceSlotChosen = "Slot1"

    if teleportData and type(teleportData) == "table" then
        if teleportData.FromAbyss or teleportData.ToAbyss then
            local slotIds = teleportData.SlotChosen or {}

            shouldSkipTitlescreen = true
            forceSlotChosen = slotIds[Players.LocalPlayer.Name] or "Slot1"

        elseif teleportData.Rejoin then
            local slotChosen = teleportData.SlotChosen
            if slotChosen then
                shouldSkipTitlescreen = true
                forceSlotChosen = slotChosen
            end
        end
    end
    if shouldSkipTitlescreen then
        workspace:SetAttribute("ShouldSkipTitlescreen", true)
    else
        repeat wait() until workspace.MapComponents:WaitForChild("Titlescreen", 999)
        repeat wait() until workspace.MapComponents.Titlescreen:WaitForChild("MainCamera", 999)
    end

    repeat wait() until plr:GetAttribute("_PlayerProfileInited")

    wait(3)
    isAlreadyLoaded = true

    if not shouldSkipTitlescreen then
        HarukaLib:UITransTween(UI, "Out", {
            TweenCallback = function()
                Fusion.doCleanup(scope)
            end
        })
    end
    workspace:SetAttribute("Haruka_CompletedPreload", true)

    if shouldSkipTitlescreen then
        workspace:SetAttribute("Titlescreen_LoadSlot", true)

        local Events = require(RepS.HarukaShared.Library.Events)

        Events.Titlescreen_SlotActions_C.Fire({
            ActionId = "Play",
            SlotId = forceSlotChosen
        })
    else
        --// init ambient
        SoundService.Musics.Titlescreen:Play()

        local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
        ClientLib:LoadLightingPreset("Titlescreen")
    end

    repeat wait() until plr.Character
    repeat wait() until plr.Character.PrimaryPart
    repeat wait() until plr.Character:GetAttribute("Haruka_CriRPGServerInited")

    workspace:SetAttribute("Haruka_TitlescreenDestroying", true)

    if shouldSkipTitlescreen then
        HarukaLib:UITransTween(UI, "Out", {
            TweenCallback = function()
                Fusion.doCleanup(scope)
            end
        })
    end
    pcall(function()
        if not workspace:GetAttribute("NoResetLightingConfig") then
            local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)

            local worldId = workspace:GetAttribute("WorldId") or "InitusWorld"
            ClientLib:LoadLightingPreset(worldId)
        end

        local insWhiteList = { "CharPreviewLocator", "MainCamera" }
        for _, ins: Instance in workspace.MapComponents.Titlescreen:GetChildren() do
            if not table.find(insWhiteList, ins.Name) then
                ins:Destroy()
            end
        end
    end)

    if SoundService.Musics:FindFirstChild("Titlescreen") then
        HarukaLib:CreateTween(SoundService.Musics.Titlescreen, TweenInfo.new(0.5), {
            Volume = 0
        }):Play()

        Debris:AddItem(SoundService.Musics.Titlescreen, 5)
    end
    workspace:SetAttribute("Haruka_GameEntered", true)

    Debris:AddItem(script, 15)
end