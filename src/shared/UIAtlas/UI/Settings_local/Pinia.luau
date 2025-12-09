
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Signal = require(RepS.HarukaShared.Shared.Signal)

local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)

local SettingsTemplate = require(script.Parent.SettingsTemplate)


export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,

    SettingsFolder: Folder,
    PanelSelected: Fusion.Value<string>,
    IsSettingsShown: Fusion.Value<boolean>,

    ValidInputBegan: Signal.SignalClass,

    SliderProgressVals: { [string]: { [string]: Fusion.Value<number> } },
    SliderVals: { [string]: { [string]: Fusion.Value<number> } },

    SwitcherVals: { [string]: { [string]: Fusion.Value<boolean> } },
    DropdownVals: { [string]: { [string]: Fusion.Value<string> } },

    IsInKeybindMode: Fusion.Value<boolean>,

    INFO: SettingsTemplate.SettingsJSON
}


return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end

    workspace:SetAttribute("UIScaleFactor", 1)
    workspace:SetAttribute("HideUIFactor", false)

    workspace:SetAttribute("RainEffectEnabled", true)

    workspace:SetAttribute("CombatMode", "Public")

    self.SettingsFolder = self.plr:WaitForChild("CriRPGSettings", 999) :: Folder

    if #self.SettingsFolder:GetChildren() > 0 then
        Bindables.CreateNotify:Fire("[System] Loaded Saved Settings!")
    end

    self.PanelSelected = Value("Game")
    self.IsSettingsShown = Value(false)

    self.ValidInputBegan = Signal.new()

    self.SliderProgressVals = {}
    self.SliderVals = {}

    self.SwitcherVals = {}
    self.DropdownVals = {}

    self.IsInKeybindMode = Value(false)

    local scope = self.scope :: Fusion.Scope


    --// track visible
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsSettingsShown:set(newPanel == "Settings")
        end
    }))


    --// track valid input
    local validKeycodeNames = {}
    local deprecated = {
        "MouseBackButton", "MouseNoButton", "MouseX", "MouseY"
    }
    for _, keycode: Enum.KeyCode in Enum.KeyCode:GetEnumItems() do
        if string.find(keycode.Name, "World") then continue end
        if table.find(deprecated, keycode.Name) then continue end
        if keycode.Name == "Unknown" then continue end

        validKeycodeNames[keycode.Name] = true
    end
    table.insert(scope, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end

        local isGamepad = string.find(input.UserInputType.Name, "Gamepad")
        local isKeyboard = string.find(input.UserInputType.Name, "Keyboard")
        if not isGamepad and not isKeyboard then return end


        if Fusion.peek(self.IsInKeybindMode) and validKeycodeNames[input.KeyCode.Name] then
            self.ValidInputBegan:Fire(input.KeyCode.Name)
        end
    end))


    --// load saved keybinds
    if HarukaLib:GetDevice() ~= "Mobile" then
        for _, symbol in self.SettingsFolder:GetChildren() do
            if symbol:IsA("StringValue") and string.find(symbol.Name, "KEYBIND") then
                local keybind = symbol.Value
                local platform = if string.find(symbol.Name, "Console") then "Console" else "PC"
                local keybindId = string.match(symbol.Name, "_(%w+)$")

                if not KeybindsBook[platform] then continue end
                if not KeybindsBook[platform][keybindId] then continue end

                KeybindsBook[platform][keybindId] = Enum.KeyCode[keybind]
                KeybindsBook.OnKeybindChanged:Fire(true)
            end
        end
    end


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
    for panelId, panelInfo in self.INFO do
        if panelId == "KeybindsPC" or panelId == "KeybindsConsole" then continue end


        self.SliderProgressVals[panelId] = {}
        self.SliderVals[panelId] = {}

        for optionId, optionInfo in panelInfo.Includes do
            if optionInfo.Type ~= "Slider" then continue end

            local defaultValue = optionInfo.DefaultValue
            if self.SettingsFolder:FindFirstChild(optionId) then
                defaultValue = self.SettingsFolder[optionId].Value
            end
            if not optionInfo.AllowDecimals then
                defaultValue = math.floor(defaultValue)
            end

            self.SliderProgressVals[panelId][optionId] = Value((defaultValue - optionInfo.Min) / (optionInfo.Max - optionInfo.Min))
            self.SliderVals[panelId][optionId] = Value(defaultValue)

            self.INFO[panelId].Includes[optionId].DefaultValue = defaultValue

            table.insert(scope, optionInfo.ValChanged)
        end
    end
    --// track switcher
    for panelId, panelInfo in self.INFO do
        if panelId == "KeybindsPC" or panelId == "KeybindsConsole" then continue end


        self.SwitcherVals[panelId] = {}

        for optionId, optionInfo in panelInfo.Includes do
            if optionInfo.Type ~= "Switcher" then continue end

            local defaultValue = optionInfo.DefaultValue
            if self.SettingsFolder:FindFirstChild(optionId) then
                defaultValue = self.SettingsFolder[optionId].Value
            end

            self.SwitcherVals[panelId][optionId] = Value(defaultValue)
        end
    end
    --// track dropdown
    for panelId, panelInfo in self.INFO do
        if panelId == "KeybindsPC" or panelId == "KeybindsConsole" then continue end


        self.DropdownVals[panelId] = {}

        for optionId, optionInfo in panelInfo.Includes do
            if optionInfo.Type ~= "Dropdown" then continue end

            local defaultValue = optionInfo.DefaultValue
            if self.SettingsFolder:FindFirstChild(optionId) then
                defaultValue = self.SettingsFolder[optionId].Value
            end

            self.DropdownVals[panelId][optionId] = Value(defaultValue)
        end
    end


    self.INFO.Sounds.Includes.MusicVolume.ValChanged:Connect(function(val: number)
        SoundService.Musics.Volume = val
    end)
    self.INFO.Sounds.Includes.SFXVolume.ValChanged:Connect(function(val: number)
        SoundService.SFXs.Volume = val
    end)
    self.INFO.Sounds.Includes.FootstepVolume.ValChanged:Connect(function(val)
        SoundService.FS_SFXs.Volume = val
    end)
    self.INFO.Sounds.Includes.AmbientVolume.ValChanged:Connect(function(val)
        SoundService.Environment.Volume = val
    end)


    self.INFO.Interface.Includes.UIScale.ValChanged:Connect(function(val: number)
        workspace:SetAttribute("UIScaleFactor", val)

        for _, ui in self.plr.PlayerGui:QueryDescendants("UIScale") do
            ui.Scale = (ui:GetAttribute("BaseScale") or 1) * val
        end
    end)



    --// track graphics
    local function _changePartToPlastic(part: BasePart)
        if part == nil then return end
        if part.Parent == nil then return end
        if not HarukaLib:IsBasePartType(part) then return end

        part:SetAttribute("OriMaterial", part.Material)
        part:SetAttribute("OriColor", part.Color)

        part.Material = Enum.Material.Plastic
        part.Color = part.Color:Lerp(Color3.fromRGB(), 0.4)

        part:AddTag("LDMTerrainPart")
    end
    local LDMObserver = Fusion.Observer(scope, self.SwitcherVals.Game.LowDetailMode)
    LDMObserver:onBind(function()
        local state = Fusion.peek(self.SwitcherVals.Game.LowDetailMode)

        if state then
            for _, part in CollectionService:GetTagged("TerrainPart") do
                _changePartToPlastic(part)
            end
            for _, tree: Model in CollectionService:GetTagged("TreeEntity") do
                for _, part in tree:GetDescendants() do
                    _changePartToPlastic(part)
                end
            end
            for _, flower: Model in CollectionService:GetTagged("FlowerEntity") do
                for _, part in flower:GetDescendants() do
                    _changePartToPlastic(part)
                end
            end
        else
            for _, part: BasePart in CollectionService:GetTagged("LDMTerrainPart") do
                if part == nil then return end
                if part.Parent == nil then return end
                if not HarukaLib:IsBasePartType(part) then return end

                if not part:GetAttribute("OriMaterial") then return end
                if not part:GetAttribute("OriColor") then return end

                local oriMaterial, oriColor =
                    part:GetAttribute("OriMaterial") :: Enum.Material,
                    part:GetAttribute("OriColor") :: Color3

                part.Material = oriMaterial
                part.Color = oriColor

                part:RemoveTag("LDMTerrainPart")
            end
        end
    end)


    local shadowsObserver = Fusion.Observer(scope, self.SwitcherVals.Game.GlobalShadows)
    shadowsObserver:onBind(function()
        local state = Fusion.peek(self.SwitcherVals.Game.GlobalShadows)

        Lighting.GlobalShadows = state
    end)


    --// track hide ui
    local hideUIObserver = Fusion.Observer(scope, self.SwitcherVals.Interface.HideUI)
    hideUIObserver:onBind(function()
        local state = Fusion.peek(self.SwitcherVals.Interface.HideUI)

        workspace:SetAttribute("HideUIFactor", state)
    end)


    --// track rain
    local rainObserver = Fusion.Observer(scope, self.SwitcherVals.Game.RainEffect)
    rainObserver:onBind(function()
        local state = Fusion.peek(self.SwitcherVals.Game.RainEffect)

        workspace:SetAttribute("RainEffectEnabled", state)
    end)


    --// track solo/public/party combat
    local combatObserver = Fusion.Observer(scope, self.DropdownVals.Game.CombatMode)
    combatObserver:onBind(function()
        local mode = Fusion.peek(self.DropdownVals.Game.CombatMode)
        mode = mode or "Public"

        workspace:SetAttribute("CombatMode", mode)
    end)
end