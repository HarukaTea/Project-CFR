--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    FilterTierList: { Fusion.Value<boolean> },
    FilterItemText: Fusion.Value<string>,
    SortMethodList: { Fusion.Value<boolean> },
})

    local function Title(text: string, order: number)
        return Components.TextLabel(scope, {
            Name = text.."Title",
            LayoutOrder = order,
            Size = UDim2.fromScale(0.9, 0.05),
            TextXAlignment = Enum.TextXAlignment.Left,

            Text = text,

            [Children] = {
                Components.UIAspectRatioConstraint(scope, 14.438),
            }
        })
    end

    return {
        Components.Frame(scope, {
            Name = "Inner",
            BackgroundTransparency = 0,

            [Children] = {
                Components.UIListLayout(scope, {
                    Padding = UDim.new(0.03, 0),
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                }),

                Components.Frame(scope, {
                    Name = "PaddingAAA",
                    Size = UDim2.new(0, 1, 0.05, 0),

                    [Children] = {
                        Components.UIAspectRatioConstraint(scope, 0.043),
                    }
                }),


                Title("Search", 1),
                Title("Includes", 4),
                Title("Sort Order", 6),


                Components.TextBox(scope, {
                    Name = "SearchBox",
                    LayoutOrder = 3,
                    Size = UDim2.fromScale(0.9, 0.06),
                    PlaceholderText = "Item Name Here",
                    TextXAlignment = Enum.TextXAlignment.Left,

                    Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return use(props.FilterItemText)
                    end),

                    [Fusion.Out("Text")] = props.FilterItemText,

                    [Children] = {
                        Components.UIAspectRatioConstraint(scope, 11.359),

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

                Components.ScrollingFrame(scope, {
                    Name = "Includes",
                    Size = UDim2.fromScale(0.95, 0.2),
                    LayoutOrder = 5,

                    [Children] = {
                        Components.UIAspectRatioConstraint(scope, 3.408),

                        Components.PaddingFrame(scope, "AAA"),
                        Components.PaddingFrame(scope, "ZZZ"),

                        Fusion.ForPairs(scope, {"I", "II", "III", "IV", "V"}, function(_, scope: Fusion.Scope, index: number, tier: string)

                            local isSelecting = Fusion.Value(scope, false)

                            return index,  Components.TextButton(scope, {
                                Name = "Tier"..index,

                                Text = "Tier "..tier,
                                TextXAlignment = Enum.TextXAlignment.Right,
                                LayoutOrder = index,
                                Size = UDim2.fromScale(0.95, 0.32),


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
                                    Components.UIAspectRatioConstraint(scope, 10.117),
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
                }, {
                    Padding = UDim.new(0, 6),
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                }),


                Components.ScrollingFrame(scope, {
                    Name = "SortOrders",
                    Size = UDim2.fromScale(0.95, 0.2),
                    LayoutOrder = 7,

                    [Children] = {
                        Components.UIAspectRatioConstraint(scope, 3.408),

                        Components.PaddingFrame(scope, "AAA"),
                        Components.PaddingFrame(scope, "ZZZ"),

                        Fusion.ForPairs(scope, {"AZ", "ZA", "T1", "T5"}, function(_, scope: Fusion.Scope, index: number, sortMethod: string)

                            local isSelecting = Fusion.Value(scope, false)

                            local TEXTS = {
                                AZ = "Sort By Name (A-Z)",
                                ZA = "Sort By Name (Z-A)",
                                T1 = "Sort By Tier (I-V)",
                                T5 = "Sort By Tier (V-I)",
                            }

                            return index,  Components.TextButton(scope, {
                                Name = "SortMethod"..index,

                                Text = TEXTS[sortMethod],
                                TextXAlignment = Enum.TextXAlignment.Right,
                                LayoutOrder = index,
                                Size = UDim2.fromScale(0.95, 0.32),


                                BackgroundTransparency = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return if use(props.SortMethodList[index]) then 0 else 1
                                end),
                                BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return if use(props.SortMethodList[index]) then Color3.fromRGB(213, 206, 193) else Color3.fromRGB(29, 37, 49)
                                end),
                                TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return if use(props.SortMethodList[index]) then Color3.fromRGB(29, 37, 49) else Color3.fromRGB(213, 206, 193)
                                end),


                                [Fusion.OnEvent("MouseEnter")] = function()
                                    isSelecting:set(true)
                                end,
                                [Fusion.OnEvent("MouseLeave")] = function()
                                    isSelecting:set(false)
                                end,
                                [Fusion.OnEvent("MouseButton1Click")] = function()
                                    for _, val in props.SortMethodList do
                                        val:set(false)
                                    end
                                    props.SortMethodList[index]:set(true)
                                end,


                                [Children] = {
                                    Components.UIAspectRatioConstraint(scope, 10.117),
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
                                            return if use(props.SortMethodList[index]) then 0 else 1
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
                                                    return use(props.SortMethodList[index])
                                                end),
                                            })
                                        }
                                    })
                                }
                            })
                        end)
                    }
                }, {
                    Padding = UDim.new(0, 6),
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                }),
            }
        }),


        Components.Frame(scope, {
            Name = "BottomBtns",
            Size = UDim2.fromScale(0.95, 0.06),
            Position = UDim2.fromScale(0.5, 0.97),
            AnchorPoint = Vector2.new(0.5, 1),

            [Children] = {
                Components.UIAspectRatioConstraint(scope, 11.957),

                ExecuteButton(scope, {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromScale(0.6, 1),
                    ButtonText = "Reset",
                    ButtonType = "Cancel",
                    ButtonClickFunc = function()
                        for _, tierStatus in props.FilterTierList do
                            tierStatus:set(true)
                        end
                        props.FilterItemText:set("")
                    end
                })
            }
        }),
    }
end