
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local CloseView = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)
local SideCategoryBtn = require(RepS.HarukaShared.UIAtlas.Components.SideCategoryBtn)

local FakeTopBGTex = require(RepS.HarukaShared.UIAtlas.Components.FakeTopBGTex)

local Slider = require(script.Components.Slider)
local Switcher = require(script.Components.Switcher)
local Dropdown = require(script.Components.Dropdown)
local Keybind = require(script.Components.Keybind)

local Children = Fusion.Children

local Pinia = require(script.Pinia)
local SettingsTemplate = require(script.SettingsTemplate)

return function (plr: Player)
    local self = {} :: Pinia.Self

    ClientLib:InitUIFramework(self, plr, "Settings", true)

    self.INFO = require(script.SettingsTemplate) :: SettingsTemplate.SettingsJSON

    Pinia(self)

    local scope = self.scope :: Fusion.Scope

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "Settings",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsSettingsShown)
        end),

        [Children] = {
            Components.Frame(scope, {
                Name = "FullCenter",
                Size = UDim2.fromScale(0.944, 0.7),
                Position = UDim2.fromScale(0.5, 0.53),

                [Children] = {
                    Components.UIAspectRatioConstraint(scope, 3.389),

                    Components.Frame(scope, {
                        Name = "Categories",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0, 0),
                        Size = UDim2.fromScale(0.2, 1),

                        [Children] = {
                            Components.UIListLayout(scope, {
                                Padding = UDim.new(0.04, 0),
                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            }),

                            Fusion.ForPairs(scope, self.INFO, function(_, scope: Fusion.Scope, panelId: string, panelInfo: {
                                PanelTitle: string,
                                LayoutOrder: number,

                                Includes: {
                                    [string]: SettingsTemplate.IncludesJSON
                                }
                            })
                                if string.find(panelId, "Keybinds") and HarukaLib:GetDevice() == "Mobile" then
                                    return panelId, nil
                                end

                                return panelId, SideCategoryBtn(scope, {
                                    PanelId = panelId,

                                    LayoutOrder = panelInfo.LayoutOrder,
                                    PanelTitle = panelInfo.PanelTitle,

                                    PanelSelected = self.PanelSelected,
                                })
                            end)
                        }
                    }),

                    Components.Frame(scope, {
                        Name = "Settings",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0.225, 0),
                        Size = UDim2.fromScale(0.775, 1),

                        [Children] = {
                            Fusion.ForPairs(scope, self.INFO, function(_, scope: Fusion.Scope, panelId: string, panelInfo: {
                                PanelTitle: string,
                                LayoutOrder: number,

                                Includes: {
                                    [string]: SettingsTemplate.IncludesJSON
                                }
                            })
                                if string.find(panelId, "Keybinds") and HarukaLib:GetDevice() == "Mobile" then
                                    return panelId, nil
                                end

                                return panelId, Components.ScrollingFrame(scope, {
                                    Name = panelId,
                                    AnchorPoint = Vector2.zero,
                                    Position = UDim2.fromScale(0, 0),

                                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(self.PanelSelected) == panelId
                                    end),

                                    [Children] = {
                                        Components.PaddingFrame(scope, "AAA"),
                                        Components.PaddingFrame(scope, "ZZZ"),

                                        Fusion.ForPairs(scope, panelInfo.Includes, function(_, scope: Fusion.Scope, optionId: string, optionInfo)
                                            if panelId == "KeybindsPC" or panelId == "KeybindsConsole" then
                                                return optionId, Keybind(scope, {
                                                    Platfrom = if panelId == "KeybindsPC" then "PC" else "Console",

                                                    KeybindId = optionId,
                                                    KeybindVal = optionInfo,

                                                    KeybindModeVal = self.IsInKeybindMode,
                                                    KeybindBegan = self.ValidInputBegan,
                                                })
                                            end

                                            if optionInfo.Type == "Slider" then
                                                return optionId, Slider(scope, {
                                                    OptionId = optionId,
                                                    OptionTitle = optionInfo.OptionTitle,
                                                    OptionInfo = optionInfo,
                                                    LayoutOrder = optionInfo.LayoutOrder,

                                                    BarProgressVal = self.SliderProgressVals[panelId][optionId],
                                                    BarVal = self.SliderVals[panelId][optionId],
                                                })

                                            elseif optionInfo.Type == "Switcher" then
                                                return optionId, Switcher(scope, {
                                                    OptionId = optionId,
                                                    OptionTitle = optionInfo.OptionTitle,
                                                    OptionInfo = optionInfo,
                                                    LayoutOrder = optionInfo.LayoutOrder,

                                                    BooleanValue = self.SwitcherVals[panelId][optionId],
                                                })

                                            elseif optionInfo.Type == "Dropdown" then
                                                return optionId, Dropdown(scope, {
                                                    OptionId = optionId,
                                                    OptionTitle = optionInfo.OptionTitle,
                                                    OptionDropdownOptions = optionInfo.DropdownOptions,
                                                    LayoutOrder = optionInfo.LayoutOrder,

                                                    DropdownValue = self.DropdownVals[panelId][optionId],
                                                })
                                            end

                                            return optionId, nil
                                        end)
                                    }
                                }, {
                                    Padding = UDim.new(0, 14),
                                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                    SortOrder = if panelId == "KeybindsPC" or panelId == "KeybindsConsole" then Enum.SortOrder.Name else Enum.SortOrder.LayoutOrder
                                })
                            end)
                        }
                    })
                }
            })
        }

    }, {
        FullProps = {
            ZIndex = 0,
            BackgroundTransparency = 0.2
        },

        TopProps = {
            Position = UDim2.fromScale(0.5, 0.02),

            [Children] = {
                CloseView(scope, {
                    ViewShownValue = self.IsSettingsShown
                }),
                FakeTopBGTex(scope)
            }
        }
    })
    self.UI = UI
end