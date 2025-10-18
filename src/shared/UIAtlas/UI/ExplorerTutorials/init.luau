--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)

local TutorialBook = require(RepS.HarukaShared.Library.TutorialBook)


local Children = Fusion.Children

return function (plr: Player)
    local self = {}

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope


    require(script.Pinia)(self)



    if plr.PlayerGui:FindFirstChild("ExplorerTutorialBook") then
        plr.PlayerGui.ExplorerTutorialBook:Destroy()
    end

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerTutorialBook",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end),


        [Children] = {
            Components.Frame(scope, {
                Name = "FullCenter",
                Size = UDim2.fromScale(0.944, 0.7),
                Position = UDim2.fromScale(0.5, 0.53),

                [Children] = {
                    Components.UIAspectRatioConstraint(scope, 3.389),

                    Components.Frame(scope, {
                        Name = "Topics",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0, 0),
                        Size = UDim2.fromScale(0.3, 1),

                        [Children] = {
                            Components.UIListLayout(scope, {
                                Padding = UDim.new(0.04, 0),
                                SortOrder = Enum.SortOrder.Name,
                            }),

                            Fusion.ForPairs(scope, TutorialBook, function(_, scope: Fusion.Scope, panelId: string, panelInfo: { any })
                                local isSelected = Fusion.Value(scope, false)
                                if panelId == "Combat" then
                                    isSelected:set(true)
                                end

                                table.insert(scope, self.PanelSwitched:Connect(function(panel: string)
                                    isSelected:set(panel == panelId)
                                end))

                                return panelId, Components.Frame(scope, {
                                    Name = panelId,
                                    BackgroundTransparency = 0,
                                    Size = UDim2.fromScale(0.7, 0.09),

                                    BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
                                        return if use(isSelected) then Color3.fromRGB(255, 247, 233) else Components.BLACK_COLOR
                                    end),

                                    [Children] = {
                                        Components.RoundUICorner(scope),
                                        Components.TextLabel(scope, {
                                            Name = "Title",
                                            Text = panelInfo.Title,
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
                        Name = "TutorialPages",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0.3, 0),
                        Size = UDim2.fromScale(0.7, 1),

                        [Children] = {
                            Fusion.ForPairs(scope, TutorialBook, function(_, scope: Fusion.Scope, panelId: string, panelInfo: { any })
                                return panelId, Components.Frame(scope, {
                                    Name = panelId,
                                    AnchorPoint = Vector2.zero,
                                    Position = UDim2.fromScale(-0.05, 0),

                                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(self.PanelSelected) == panelId
                                    end),

                                    [Children] = {
                                        Components.ImageLabel(scope, {
                                            Name = "Thumbnail",
                                            AnchorPoint = Vector2.new(0.5, 0),
                                            Position = UDim2.fromScale(0.5, 0),
                                            Size = UDim2.fromScale(0.5, 0.67),
                                            Image = panelInfo.Thumbnail,
                                            BackgroundTransparency = 0,
                                            BackgroundColor3 = Components.BLACK_COLOR,

                                            [Children] = {
                                                Components.UICorner(scope, {
                                                    CornerRadius = UDim.new(0.05, 0),
                                                })
                                            }
                                        }),

                                        Components.TextLabel(scope, {
                                            Name = "Desc",
                                            AnchorPoint = Vector2.yAxis,
                                            Position = UDim2.fromScale(0, 1),
                                            Size = UDim2.fromScale(1, 0.25),
                                            LineHeight = 1.2,
                                            TextScaled = false,
                                            TextWrapped = true,
                                            RichText = true,
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            TextYAlignment = Enum.TextYAlignment.Top,
                                            Text = HarukaLib:RichTextify(panelInfo.Desc),

                                            [Fusion.Out("AbsoluteSize")] = self.AbsTopicDescSize,

                                            TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                return use(self.AbsTopicDescSize).Y / (81 / 23)
                                            end),

                                            [Children] = {
                                                Components.TextUIStroke(scope, {
                                                    Thickness = 2
                                                })
                                            }
                                        })
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
            BackgroundTransparency = 0.3,
            ZIndex = 0,
        },

        TopProps = {
            Position = UDim2.fromScale(0.5, 0.02),

            [Children] = {
                CloseTab(scope, {
                    ViewShownValue = self.IsUIShown
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
    self.UI = UI


    return function ()
        Fusion.doCleanup(scope)


    end
end