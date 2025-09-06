--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    MerchantId: string
})

    local blur = Instance.new("BlurEffect")
    blur.Enabled = true
    blur.Name = "UIBlur_TicketPurchase"
    blur.Parent = workspace.CurrentCamera


    local absDescSize = Fusion.Value(scope, Vector2.zero)


    local frame; frame = Components.Frame(scope, {
        Name = "TicketPurchase",
        Size = UDim2.fromScale(0.55, 6),

        [Children] = {
            Components.UICorner(scope, {
                CornerRadius = UDim.new(0.02, 0)
            }),

            Components.Frame(scope, {
                Name = "Left",
                Size = UDim2.fromScale(0.55, 1),
                AnchorPoint = Vector2.zero,
                Position = UDim2.fromScale(0, 0),
                BackgroundTransparency = 0.25,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),

                [Children] = {
                    Components.UICorner(scope, {
                        CornerRadius = UDim.new(0.02, 0)
                    }),

                    Components.TextLabel(scope, {
                        Name = "Title",
                        Position = UDim2.fromScale(0.05, 0.05),
                        Size = UDim2.fromScale(0.25, 0.1),
                        BackgroundTransparency = 0,
                        Text = "Ticket",

                        [Children] = {
                            Components.RoundUICorner(scope),
                            Components.UIPadding(scope, {})
                        }
                    }),

                    Components.Frame(scope, {
                        Name = "ItemIcon",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0.05, 0.2),
                        Size = UDim2.fromScale(0.9, 0.4),
                        BackgroundTransparency = 0.5,
                        BackgroundColor3 = Color3.fromRGB(60, 60, 60),


                        [Fusion.Out("AbsoluteSize")] = absDescSize,

                        [Children] = {
                            Components.UICorner(scope, {
                                CornerRadius = UDim.new(0.05, 0)
                            }),
                            Components.IconImageLabel(scope, {
                                Size = UDim2.fromScale(0.5, 0.5),
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromScale(0.5, 0.5),
                                Image = "rbxassetid://93309091471652"
                            })
                        }
                    }),

                    Components.TextLabel(scope, {
                        Name = "TicketDesc",
                        Position = UDim2.fromScale(0.05, 0.65),
                        Size = UDim2.fromScale(0.9, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        LineHeight = 1.2,
                        Text = "This ticket entitles the holder to a round-trip to any location under the association's vast network of ports.",
                        TextColor3 = Components.BLACK_COLOR,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        TextScaled = false,
                        TextWrapped = true,

                        TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(absDescSize).Y / (109 / 20)
                        end)
                    })
                }
            }),

            Components.Frame(scope, {
                Name = "Right",
                Size = UDim2.fromScale(0.45, 1),
                AnchorPoint = Vector2.zero,
                Position = UDim2.fromScale(0.55, 0),
                BackgroundTransparency = 0,

                [Children] = {
                    Components.UICorner(scope, {
                        CornerRadius = UDim.new(0.02, 0)
                    }),

                    Components.Frame(scope, {
                        Name = "ItemPrice",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0, 0.1),
                        Size = UDim2.fromScale(1, 0.115),

                        [Children] = {
                            Components.UIListLayout(scope, {
                                FillDirection = Enum.FillDirection.Horizontal,
                                Padding = UDim.new(0.02, 0),
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            }),

                            Components.TextLabel(scope, {
                                Name = "Title",
                                AutomaticSize = Enum.AutomaticSize.X,
                                Size = UDim2.fromScale(0, 0.8),
                                LayoutOrder = 1,
                                RichText = true,
                                Text = "<u>Price</u>"
                            }),

                            Components.IconImageLabel(scope, {
                                Image = "rbxassetid://18421784947",
                                LayoutOrder = 2
                            }),

                            Components.TextLabel(scope, {
                                Name = "Price",
                                AutomaticSize = Enum.AutomaticSize.X,
                                Size = UDim2.fromScale(0, 0.8),
                                LayoutOrder = 3,
                                Text = "599"
                            }),
                        }
                    }),

                    Components.TextButton(scope, {
                        Name = "PurchaseButton",
                        AnchorPoint = Vector2.new(0.5, 1),
                        Position = UDim2.fromScale(0.5, 0.9),
                        Size = UDim2.fromScale(0.5, 0.1),
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Components.GREEN_COLOR,
                        TextColor3 = Components.BLACK_COLOR,
                        Text = "Purchase",

                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            Events.RequestToPurchaseTicket.Fire({
                                MerchantId = props.MerchantId
                            })

                            if blur then blur:Destroy() end
                            if frame then frame:Destroy() end
                        end,

                        [Children] = {
                            Components.RoundUICorner(scope),
                            Components.UIPadding(scope, {})
                        }
                    }),

                    Components.TextButton(scope, {
                        Name = "CancelButton",
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.fromScale(1.03, -0.03),
                        BackgroundColor3 = Components.RED_COLOR,
                        BackgroundTransparency = 0,
                        TextColor3 = Components.BLACK_COLOR,
                        Text = "X",
                        FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                        Size = UDim2.fromScale(0.125, 0.125),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,

                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            if blur then blur:Destroy() end
                            if frame then frame:Destroy() end
                        end,

                        [Children] = {
                            Components.RoundUICorner(scope),
                            Components.UIPadding(scope, {})
                        }
                    })
                }
            })
        }
    })


    return frame, blur
end
