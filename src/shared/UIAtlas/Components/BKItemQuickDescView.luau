
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

local CFEmblemTex = require(RepS.HarukaShared.UIAtlas.Components.CFEmblemTex)
local StarTierSymbol = require(RepS.HarukaShared.UIAtlas.Components.StarTierSymbol)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    Item: string,
    ItemVal: Fusion.Value<string>,

    IsViewingVal: Fusion.Value<boolean>
})

    local absTextSize = Fusion.Value(scope, Vector2.zero)
    local isSelectingClose = Fusion.Value(scope, false)

    local info = ItemBook:GetItemInfo(props.Item)
    if not info then return nil end


    return Components.Frame(scope, {
        Name = "ItemQuickDesc",
        BackgroundTransparency = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.8),
        Size = UDim2.fromScale(0.28, 7),

        Visible = Fusion.Computed(scope, function()
            return ItemBook:GetItemInfo(props.Item) ~= nil
        end),

        [Children] = {
            Components.UICorner(scope, { CornerRadius = UDim.new(0.015, 0) }),

            Components.ScaledUIStroke(scope, {
                Thickness = 0.02,
                Color = Color3.new()
            }),

            Components.UIListLayout(scope, {
                Padding = UDim.new(0.03, 0),
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),

            Components.PaddingFrame(scope, "AAA"),


            Components.Frame(scope, {
                Name = "ItemName",
                LayoutOrder = 2,
                Size = UDim2.fromScale(0.9, 0.1),

                [Children] = {
                    Components.UIAspectRatioConstraint(scope, 9.093),

                    Components.Frame(scope, {
                        Name = "LeftOrder",

                        [Children] = {
                            Components.UIListLayout(scope, {
                                Padding = UDim.new(0.05, 0),
                                FillDirection = Enum.FillDirection.Horizontal,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                            }),

                            Components.Frame(scope, {
                                Name = "TierIndicator",
                                Size = UDim2.fromScale(0.02, 0.65),

                                BackgroundTransparency = 0,
                                BackgroundColor3 = AssetBook.ItemTierColors[info.Tier]
                            }),
                            Components.TextLabel(scope, {
                                Name = "ItemName",
                                Size = UDim2.fromScale(0, 0.7),
                                AutomaticSize = Enum.AutomaticSize.X,
                                TextXAlignment = Enum.TextXAlignment.Left,

                                Text = info.Name,
                            }),
                        }
                    }),
                    Components.Frame(scope, {
                        Name = "RightOrder",
                        Size = UDim2.fromScale(1.05, 1),

                        [Children] = {
                            Components.UIListLayout(scope, {
                                Padding = UDim.new(0.05, 0),
                                FillDirection = Enum.FillDirection.Horizontal,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                            }),

                            Components.Frame(scope, {
                                Name = "Close",
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                Size = UDim2.fromScale(1.4, 1.4),

                                [Children] = {
                                    Components.ImageLabel(scope, {
                                        Name = "Icon",
                                        Image = "rbxassetid://82804434423267",

                                        ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            return if use(isSelectingClose) then Color3.fromRGB(255, 255, 0) else Color3.new(1, 1, 1)
                                        end)
                                    }),
                                    Components.HoverImageButton(scope, {
                                        [Fusion.OnEvent("MouseEnter")] = function()
                                            isSelectingClose:set(true)
                                        end,
                                        [Fusion.OnEvent("MouseLeave")] = function()
                                            isSelectingClose:set(false)
                                        end,
                                        [Fusion.OnEvent("MouseButton1Click")] = function()
                                            props.IsViewingVal:set(false)
                                            props.ItemVal:set("")
                                        end
                                    })
                                }
                            })
                        }
                    }),
                }
            }),

            Components.Frame(scope, {
                Name = "ItemInfo",
                LayoutOrder = 4,
                Size = UDim2.fromScale(0.9, 0.8),

                [Children] = {
                    Components.UIListLayout(scope, {
                        Padding = UDim.new(0.05, 0),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center
                    }),

                    Components.Frame(scope, {
                        Name = "ItemIcon",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0,
                        Size = UDim2.fromScale(0.95, 0.3),
                        LayoutOrder = 1,
                        ClipsDescendants = true,

                        [Children] = {
                            Components.UICorner(scope, { CornerRadius = UDim.new(0.1, 0) }),

                            Components.UIGradient(scope, {
                                Color = ColorSequence.new(
                                    AssetBook.ItemTierColors[info.Tier]:Lerp(Color3.new(1, 1, 1), 0.6),
                                    AssetBook.ItemTierColors[info.Tier]
                                ),
                                Rotation = 60,
                                Transparency = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 0.75),
                                    NumberSequenceKeypoint.new(1, 0.5)
                                })
                            }),

                            Components.IconImageLabel(scope, {
                                AnchorPoint = Vector2.new(0, 0.5),
                                Position = UDim2.fromScale(0.75, 0.5),
                                Size = UDim2.fromScale(0.2, 0.2),
                                SizeConstraint = Enum.SizeConstraint.RelativeXX,

                                Image = info.Icon
                            }),

                            Components.Frame(scope, {
                                Name = "ItemTiers",
                                AnchorPoint = Vector2.new(0.5, 1),
                                Position = UDim2.fromScale(0.5, 0.9),
                                Size = UDim2.fromScale(0.9, 0.22),

                                [Children] = {
                                    Components.UIListLayout(scope, {
                                        FillDirection = Enum.FillDirection.Horizontal,
                                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                                        VerticalAlignment = Enum.VerticalAlignment.Center,
                                    }),

                                    Fusion.ForPairs(scope, table.create(info.Tier, true), function(_, scope: Fusion.Scope, index: number, _)
                                        return index, StarTierSymbol(scope, {})
                                    end)
                                }
                            }),

                            CFEmblemTex(scope, {
                                Transparency = 0.91,
                                Position = UDim2.fromScale(0.3, 0.5)
                            })
                        }
                    }),

                    Components.Frame(scope, {
                        Name = "HorizontalLine",
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BackgroundTransparency = 0.5,
                        Size = UDim2.fromScale(1, 0.01),
                        LayoutOrder = 2,
                    }),


                    Components.TextLabel(scope, {
                        Name = "ItemObtainMethods",
                        Size = UDim2.fromScale(0.95, 0.6),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        TextScaled = false,
                        TextWrapped = true,
                        LineHeight = 1.2,
                        TextColor3 = Color3.fromRGB(159, 159, 159),
                        LayoutOrder = 3,

                        [Fusion.Out("AbsoluteSize")] = absTextSize,

                        TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(absTextSize).Y / (153 / 22)
                        end),
                        Text = info.ObtainMethod
                    })
                }
            })
        }
    })
end