--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    FilterTierList: { Fusion.Value }
})
    return {
        Components.Frame(scope, {
            Name = "Inner",

            [Children] = {
                Components.UIListLayout(scope, {
                    Padding = UDim.new(0.03, 0),
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                }),

                Components.Frame(scope, {
                    Name = "PaddingAAA",
                    Size = UDim2.fromScale(1, 0.01),

                    [Children] = {
                        Components.UIAspectRatioConstraint(scope, 102.508),
                    }
                }),

                Components.TextLabel(scope, {
                    Name = "Title",
                    LayoutOrder = 1,
                    Size = UDim2.fromScale(0.9, 0.08),
                    TextXAlignment = Enum.TextXAlignment.Left,

                    Text = "Search",

                    [Children] = {
                        Components.UIAspectRatioConstraint(scope, 11.532),
                    }
                }),
                Components.TextLabel(scope, {
                    Name = "Title",
                    LayoutOrder = 4,
                    Size = UDim2.fromScale(0.9, 0.08),
                    TextXAlignment = Enum.TextXAlignment.Left,

                    Text = "Includes",

                    [Children] = {
                        Components.UIAspectRatioConstraint(scope, 11.532),
                    }
                }),

                Components.TextBox(scope, {
                    Name = "SearchBox",
                    LayoutOrder = 3,
                    Size = UDim2.fromScale(0.9, 0.08),
                    PlaceholderText = "Item Name Here",
                    TextXAlignment = Enum.TextXAlignment.Left,

                    Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return use(props.FilterItemText)
                    end),

                    [Fusion.Out("Text")] = props.FilterItemText,

                    [Children] = {
                        Components.UIAspectRatioConstraint(scope, 11.532),

                        Components.RoundUICorner(scope),
                        Components.UIStroke(scope, {
                            Thickness = 1.5,
                            Transparency = 0.1,
                            Color = Color3.fromRGB(213, 206, 193)
                        }),

                        Components.UIPadding(scope, {
                            PaddingTop = UDim.new(0.17, 0),
                            PaddingBottom = UDim.new(0.17, 0)
                        }),

                        Components.ImageLabel(scope, {
                            Name = "SearchIcon",
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.fromScale(-0.1, 0.5),
                            Size = UDim2.fromScale(0.8, 0.8),
                            SizeConstraint = Enum.SizeConstraint.RelativeYY,
                            Image = "rbxassetid://82194349460454",
                            ImageColor3 = Color3.fromRGB(213, 206, 193)
                        })
                    }
                }),

                Components.Frame(scope, {
                    Name = "Includes",
                    Size = UDim2.fromScale(0.95, 0.5),
                    LayoutOrder = 5,

                    [Children] = {
                        Components.UIGridLayout(scope, {
                            CellSize = UDim2.fromScale(0.46, 0.21),
                            CellPadding = UDim2.fromScale(0.05, 0.1),
                            HorizontalAlignment = Enum.HorizontalAlignment.Center
                        }),

                        Fusion.ForPairs(scope, {"I", "II", "III", "IV", "V"}, function(_, scope: Fusion.Scope, index: number, tier: number)

                            local isSelecting = Fusion.Value(scope, false)

                            return index,  Components.TextButton(scope, {
                                Name = "Tier"..index,

                                Text = "Tier "..tier,
                                TextXAlignment = Enum.TextXAlignment.Right,
                                LayoutOrder = index,


                                BackgroundTransparency = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return if use(props.FilterTierList[index]) then 0 else 1
                                end),
                                BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return if use(props.FilterTierList[index]) then Color3.fromRGB(213, 206, 193) else Color3.fromRGB(29, 37, 49)
                                end),
                                TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return if use(props.FilterTierList[index]) then Color3.fromRGB(29, 37, 49) else Color3.fromRGB(213, 206, 193)
                                end),


                                [Fusion.OnEvent("MouseEnter")] = function()
                                    isSelecting:set(true)
                                end,
                                [Fusion.OnEvent("MouseLeave")] = function()
                                    isSelecting:set(false)
                                end,
                                [Fusion.OnEvent("MouseButton1Click")] = function()
                                    props.FilterTierList[index]:set(not Fusion.peek(props.FilterTierList[index]))
                                end,


                                [Children] = {
                                    Components.UICorner(scope, { CornerRadius = UDim.new(0.05, 0) }),

                                    Components.UIStroke(scope, {
                                        Thickness = 1,
                                        Color = Color3.fromRGB(213, 206, 193)
                                    }),

                                    Components.UIPadding(scope, {
                                        PaddingTop = UDim.new(0.2, 0),
                                        PaddingBottom = UDim.new(0.2, 0),
                                    }),

                                    Components.UIListLayout(scope, {
                                        FillDirection = Enum.FillDirection.Horizontal,
                                        VerticalAlignment = Enum.VerticalAlignment.Center,
                                    }),

                                    Components.Frame(scope, {
                                        Name = "IsSelected",
                                        Size = UDim2.fromScale(0.92, 0.92),
                                        SizeConstraint = Enum.SizeConstraint.RelativeYY,

                                        BackgroundTransparency = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            return if use(props.FilterTierList[index]) then 0 else 1
                                        end),


                                        [Children] = {
                                            Components.RoundUICorner(scope),
                                            Components.UIStroke(scope, {
                                                Thickness = 1,
                                                Color = Color3.fromRGB(213, 206, 193),
                                            }),

                                            Components.ImageLabel(scope, {
                                                Name = "SelectedIcon",
                                                Image = "rbxassetid://125595342982836",
                                                ImageColor3 = Color3.fromRGB(85, 255, 127),

                                                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                    return use(props.FilterTierList[index])
                                                end),
                                            })
                                        }
                                    })
                                }
                            })
                        end)
                    }
                }),
            }
        }),


        Components.Frame(scope, {
            Name = "Inner2",

            [Children] = {
                Components.UIListLayout(scope, {
                    Padding = UDim.new(0.03, 0),
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Bottom,
                }),

                Components.Frame(scope, {
                    Name = "PaddingAAA",
                    LayoutOrder = 999,
                    Size = UDim2.fromScale(1, 0.01),

                    [Children] = {
                        Components.UIAspectRatioConstraint(scope, 102.508),
                    }
                }),


                Components.Frame(scope, {
                    Name = "BottomBtns",
                    Size = UDim2.fromScale(0.95, 0.11),
                    LayoutOrder = 1,

                    [Children] = {
                        Components.UIAspectRatioConstraint(scope, 8.853),

                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                        }),

                        ExecuteButton(scope, {
                            LayoutOrder = 1,
                            Size = UDim2.fromScale(0.9, 0.8),
                            ButtonText = "Reset",
                            ButtonType = "Cancel",
                            ButtonClickFunc = function()
                                for _, tierStatus: Fusion.Value in props.FilterTierList do
                                    tierStatus:set(true)
                                end
                                props.FilterItemText:set("")
                            end
                        })
                    }
                })
            }
        })
    }
end
