--!nocheck

local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Signal = require(RepS.HarukaShared.Shared.Signal)


return function (self: table)
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end

    workspace:SetAttribute("UIScaleFactor", 1)

    self.PanelSelected = Value("Graphics")
    self.IsSettingsShown = Value(false)

    self.PanelSwitched = Signal.new()

    self.SliderProgressVals = {}
    self.SliderVals = {}

    self.SwitcherVals = {}

    local scope = self.scope :: Fusion.Scope


    --// track visible
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsSettingsShown:set(newPanel == "Settings")
        end
    }))


    --// track ui blur
    local blur = Components.BlurFS(scope, {
        Name = "UIBlur_Settings",
        Size = 21,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsSettingsShown)
        end)
    })
    blur.Parent = workspace.CurrentCamera


    --// track slider
    for panelId: string, panelInfo: table in self.INFO do
        self.SliderProgressVals[panelId] = {}
        self.SliderVals[panelId] = {}

        for optionId: string, optionInfo: table in panelInfo.Includes do
            if optionInfo.Type ~= "Slider" then continue end

            self.SliderProgressVals[panelId][optionId] = Value((optionInfo.DefaultValue - optionInfo.Min) / (optionInfo.Max - optionInfo.Min))
            self.SliderVals[panelId][optionId] = Value(optionInfo.DefaultValue)

            table.insert(scope, optionInfo.ValChanged)
        end
    end
    --// track switcher
    for panelId: string, panelInfo: table in self.INFO do
        self.SwitcherVals[panelId] = {}

        for optionId: string, optionInfo: table in panelInfo.Includes do
            if optionInfo.Type ~= "Switcher" then continue end

            self.SwitcherVals[panelId][optionId] = Value(optionInfo.DefaultValue)
        end
    end


    self.INFO.Sounds.Includes.MusicVolume.ValChanged:Connect(function(val: number)
        SoundService.Musics.Volume = val
    end)
    self.INFO.Sounds.Includes.SFXVolume.ValChanged:Connect(function(val: number)
        SoundService.SFXs.Volume = val
    end)


    self.INFO.Interface.Includes.UIScale.ValChanged:Connect(function(val: number)
        workspace:SetAttribute("UIScaleFactor", val)

        for _, ui: GuiObject in self.plr.PlayerGui:GetDescendants() do
            if ui:IsA("UIScale") then
                ui.Scale = (ui:GetAttribute("BaseScale") or 1) * val
            end
        end
    end)



    --// track graphics
    local LDMObserver = Fusion.Observer(scope, self.SwitcherVals.Graphics.LowDetailMode)
    local alreadyLDM = false
    LDMObserver:onBind(function()
        local state = Fusion.peek(self.SwitcherVals.Graphics.LowDetailMode)

        if state and not alreadyLDM then
            alreadyLDM = true

            local function _changePartToPlastic(part: BasePart)
                if part == nil then return end
                if part.Parent == nil then return end
                if not HarukaLib:IsBasePartType(part) then return end

                part.Material = Enum.Material.SmoothPlastic
                part.Color = part.Color:Lerp(Color3.fromRGB(), 0.4)
            end
            for _, part in CollectionService:GetTagged("TerrainPart") do
                _changePartToPlastic(part)
            end
            for _, tree: Model in CollectionService:GetTagged("TreeEntity") do
                tree:Destroy()
            end
            for _, flower: Model in CollectionService:GetTagged("FlowerEntity") do
                flower:Destroy()
            end

            workspace:SetAttribute("LowDetailMode", true)

        elseif not state and alreadyLDM then
            Bindables.CreateNotify:Fire("You must re-enter the game to disable Low-Detail Mode.")
        end
    end)


    local shadowsObserver = Fusion.Observer(scope, self.SwitcherVals.Graphics.GlobalShadows)
    shadowsObserver:onBind(function()
        local state = Fusion.peek(self.SwitcherVals.Graphics.GlobalShadows)

        Lighting.GlobalShadows = state
    end)
end
