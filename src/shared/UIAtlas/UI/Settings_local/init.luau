--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local CloseView = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)

local SliderForSettings = require(script.Components.Slider)
local Dropdown = require(script.Components.Dropdown)
local Switcher = require(script.Components.Switcher)

local Children = Fusion.Children

return function (plr: Player)
    local self = {}

    self.plr = plr
    self.scope = Fusion.scoped()

    self.INFO = require(script.SettingsTemplate)


    require(script.Pinia)(self)


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
                        Size = UDim2.fromScale(0.3, 1),

                        [Children] = {
                            Components.UIListLayout(scope, {
                                Padding = UDim.new(0.04, 0),
                            }),

                            Fusion.ForPairs(scope, self.INFO, function(_, scope: Fusion.Scope, panelId: string, panelInfo: table)
                                local isSelected = Fusion.Value(scope, false)
                                if panelInfo.LayoutOrder == 1 then
                                    isSelected:set(true)
                                end

                                table.insert(scope, self.PanelSwitched:Connect(function(panel: string)
                                    isSelected:set(panel == panelId)
                                end))

                                return panelId, Components.Frame(scope, {
                                    Name = panelId,
                                    BackgroundTransparency = 0,
                                    Size = UDim2.fromScale(0.7, 0.09),
                                    LayoutOrder = panelInfo.LayoutOrder,

                                    BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
                                        return if use(isSelected) then Color3.fromRGB(255, 247, 233) else Components.BLACK_COLOR
                                    end),

                                    [Children] = {
                                        Components.RoundUICorner(scope),
                                        Components.TextLabel(scope, {
                                            Name = "Title",
                                            Text = panelInfo.PanelTitle,
                                            TextXAlignment = Enum.TextXAlignment.Left,

                                            TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
                                                return if use(isSelected) then Components.BLACK_COLOR else Color3.fromRGB(255, 247, 233)
                                            end),

                                            [Children] = {
                                                Components.UIPadding(scope, {})
                                            }
                                        }),

                                        Components.HoverImageButton(scope, {
                                            [Fusion.OnEvent("MouseEnter")] = function()
                                                isSelected:set(true)
                                            end,
                                            [Fusion.OnEvent("MouseLeave")] = function()
                                                if Fusion.peek(self.PanelSelected) == panelId then return end

                                                isSelected:set(false)
                                            end,

                                            [Fusion.OnEvent("MouseButton1Click")] = function()
                                                self.PanelSelected:set(panelId)
                                                self.PanelSwitched:Fire(panelId)
                                            end
                                        })
                                    }

                                })
                            end)
                        }
                    }),

                    Components.Frame(scope, {
                        Name = "Settings",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0.3, 0),
                        Size = UDim2.fromScale(0.7, 1),

                        [Children] = {
                            Fusion.ForPairs(scope, self.INFO, function(_, scope: Fusion.Scope, panelId: string, panelInfo: table)
                                return panelId, Components.Frame(scope, {
                                    Name = panelId,

                                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(self.PanelSelected) == panelId
                                    end),

                                    [Children] = {
                                        Components.UIListLayout(scope, {
                                            Padding = UDim.new(0.05, 0),
                                        }),

                                        Fusion.ForPairs(scope, panelInfo.Includes, function(_, scope: Fusion.Scope, optionId: string, optionInfo: table)
                                            if optionInfo.Type == "Slider" then
                                                return optionId, SliderForSettings(scope, {
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
                                            end

                                            return optionId, nil
                                        end)
                                    }
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

                Components.Frame(scope, {
                    Name = "FakeTopBG",
                    BackgroundTransparency = 0.1,
                    Size = UDim2.fromScale(2, 1.8),
                    ZIndex = 0,
                })
            }
        }
    })


    require(script.Anims)(UI, self)
end