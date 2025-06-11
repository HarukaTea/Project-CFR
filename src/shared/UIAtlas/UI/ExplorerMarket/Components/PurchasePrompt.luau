--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ItemLib = require(RepS.HarukaShared.Library.ItemLib)

local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)

local Children = Fusion.Children

local wait = task.wait

return function(scope: Fusion.Scope, props: {
    ProductId: string,
    UniqueId: string,

    IsPurchasing: Fusion.Value,
    Action: string,

    CurrentSelectedItem: Fusion.Value,
    CurrentSelectedItemUniqueId: Fusion.Value
})

    local info = ItemLib:GetItemInfo(props.ProductId)
    if info == nil then return nil end


    local function Value(val: any) : Fusion.Value
        return Fusion.Value(scope, val)
    end
    local itemAmount = Value(0)


    if props.Action == "Sell" then
        local itemSymbol: IntConstrainedValue = nil
        for _, item: IntConstrainedValue in Players.LocalPlayer.Items:GetChildren() do
            if item:GetAttribute("HarukaUniqueId") == props.UniqueId then
                itemSymbol = item
                break
            end
        end
        if itemSymbol == nil then return nil end

        itemAmount:set(itemSymbol.Value)

    elseif props.Action == "Purchase" then
        local amount = 0

        for _, item: IntConstrainedValue in Players.LocalPlayer.Items:GetChildren() do
            if item.Name == props.ProductId then
                amount += item.Value
            end
        end

        itemAmount:set(amount)
    else
        return nil
    end
    local absTextSize = Value(Vector2.zero)

    local inputTextbox = Components.TextBox(scope, {
        Name = "AmountInput",
        BackgroundColor3 = Color3.new(),
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(0.5, 1),
        LayoutOrder = 2,
        PlaceholderText = "1",

        [Children] = {
            Components.RoundUICorner(scope),
            Components.UIPadding(scope, {})
        }
    })
    local amount = ClientLib:TrackInputTextbox({
        Scope = scope,
        TextBox = inputTextbox,

        Callback = function(amount: Fusion.Value)
            local function _setColor(color: Color3)
                inputTextbox.TextColor3 = color
            end
            local curAmount = tonumber(Fusion.peek(amount))

            if curAmount == nil then _setColor(Color3.fromHex('#ff6b81')) return end
            if curAmount ~= curAmount then _setColor(Color3.fromHex('#ff6b81')) return end

            if curAmount < 1 then _setColor(Color3.fromHex('#ff6b81')) return end
            if curAmount > 99 then _setColor(Color3.fromHex('#ff6b81')) return end

            _setColor(Color3.fromRGB(255, 255, 255))
        end
    })


    return Components.Frame(scope, {
        Name = "PurchasePrompt",
        Size = UDim2.fromScale(0.5, 8),
        BackgroundTransparency = 0,

        [Children] = {
            Components.UICorner(scope, { CornerRadius = UDim.new(0.025, 0) }),
            Components.UIStroke(scope, {
                Thickness = 4,
                Color = Color3.fromRGB()
            }),

            Components.Frame(scope, {
                Name = "InnerFakeStroke",
                Size = UDim2.fromScale(0.95, 0.92),

                [Children] = {
                    Components.UICorner(scope, { CornerRadius = UDim.new(0.025, 0) }),
                    Components.UIStroke(scope, {
                        Thickness = 2.5,
                        Transparency = 0.7,
                        Color = Color3.fromRGB(174, 159, 128)
                    }),
                }
            }),


            Components.Frame(scope, {
                Name = "Div",
                Size = UDim2.fromScale(0.9, 0.87),

                [Children] = {
                    Components.UIListLayout(scope, {
                        Padding = UDim.new(0.04, 0)
                    }),

                    Components.TextLabel(scope, {
                        Name = "Title",
                        Size = UDim2.fromScale(1, 0.09),
                        RichText = true,
                        LayoutOrder = 1,

                        Text = `<u>{props.Action}</u>`
                    }),

                    Components.Frame(scope, {
                        Name = "ItemIcon",
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Size = UDim2.fromScale(1, 0.25),
                        LayoutOrder = 2,

                        [Fusion.Out("AbsoluteSize")] = absTextSize,

                        [Children] = {
                            Components.UICorner(scope, { CornerRadius = UDim.new(0.08, 0) }),

                            Components.UIGradient(scope, {
                                Rotation = 60,

                                Color = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return ColorSequence.new(
                                        AssetBook.TierColorsType2[use(info).Tier]:Lerp(Color3.new(), 0.5),
                                        AssetBook.TierColorsType2[use(info).Tier]
                                    )
                                end),
                            }),

                            Components.IconImageLabel(scope, {
                                AnchorPoint = Vector2.new(0, 0.5),
                                Size = UDim2.fromScale(0.7, 0.7),
                                Position = UDim2.fromScale(0.037, 0.5),

                                Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return use(info).Icon
                                end)
                            }),

                            Components.TextLabel(scope, {
                                Name = "ItemName",
                                Position = UDim2.fromScale(0.16, 0.1),
                                Size = UDim2.fromScale(0.81, 0.3),
                                TextXAlignment = Enum.TextXAlignment.Left,

                                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return use(info).Name
                                end)
                            }),

                            Components.TextLabel(scope, {
                                Name = "ItemDesc",
                                Position = UDim2.fromScale(0.16, 0.4),
                                Size = UDim2.fromScale(0.81, 0.5),
                                TextWrapped = true,
                                TextScaled = false,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                TextYAlignment = Enum.TextYAlignment.Top,
                                TextTruncate = Enum.TextTruncate.AtEnd,
                                TextTransparency = 0.4,

                                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return use(info).Desc
                                end),
                                TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return use(absTextSize).Y / (79 / 18)
                                end)
                            })
                        }
                    }),

                    Components.Frame(scope, {
                        Name = "ItemPurchaseAmount",
                        Size = UDim2.fromScale(1, 0.2),
                        LayoutOrder = 3,

                        [Children] = {
                            Components.TextLabel(scope, {
                                Name = "Title",
                                Size = UDim2.fromScale(1, 0.35),

                                Text = `{props.Action} Amount`
                            }),

                            Components.Frame(scope, {
                                Name = "DraggerBar",
                                AnchorPoint = Vector2.zero,
                                Size = UDim2.fromScale(1, 0.45),
                                Position = UDim2.fromScale(0, 0.55),

                                [Children] = {
                                    Components.UIListLayout(scope, {
                                        Padding = UDim.new(0.03, 0),
                                        FillDirection = Enum.FillDirection.Horizontal,
                                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                        VerticalAlignment = Enum.VerticalAlignment.Center,
                                    }),

                                    Components.TextButton(scope, {
                                        Name = "DecreaseBtn",
                                        AutoButtonColor = true,
                                        BackgroundColor3 = Color3.fromRGB(255, 118, 117),
                                        TextColor3 = Components.BLACK_COLOR,
                                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                        FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                                        Text = "-",
                                        LayoutOrder = 1,

                                        [Fusion.OnEvent("MouseButton1Click")] = function()
                                            local curAmount = Fusion.peek(amount)

                                            local nextAmount = curAmount - 1
                                            nextAmount = math.clamp(nextAmount, 1, 99)

                                            amount:set(nextAmount)
                                        end,

                                        [Children] = {
                                            Components.RoundUICorner(scope)
                                        }
                                    }),

                                    inputTextbox,

                                    Components.TextButton(scope, {
                                        Name = "IncreaseBtn",
                                        AutoButtonColor = true,
                                        BackgroundColor3 = Color3.fromRGB(123, 237, 159),
                                        TextColor3 = Components.BLACK_COLOR,
                                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                        FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                                        Text = "+",
                                        LayoutOrder = 3,

                                        [Fusion.OnEvent("MouseButton1Click")] = function()
                                            local curAmount = Fusion.peek(amount)

                                            local nextAmount = curAmount + 1
                                            nextAmount = math.clamp(nextAmount, 1, 99)

                                            amount:set(nextAmount)
                                        end,

                                        [Children] = {
                                            Components.RoundUICorner(scope)
                                        }
                                    }),

                                }
                            })
                        }
                    }),


                    Components.Frame(scope, {
                        Name = "ItemPurchasePrice",
                        Size = UDim2.fromScale(1, 0.178),
                        LayoutOrder = 4,

                        [Children] = {
                            Components.Frame(scope, {
                                AnchorPoint = Vector2.zero,
                                Position = UDim2.fromScale(0, 0),
                                Name = "ItemTags",
                                Size = UDim2.fromScale(1, 0.392),

                                [Children] = {
                                    Components.UIListLayout(scope, {
                                        FillDirection = Enum.FillDirection.Horizontal,
                                        Padding = UDim.new(0.02, 0),
                                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                    }),

                                    Components.TextLabel(scope, {
                                        Name = "YouOwned",
                                        AutomaticSize = Enum.AutomaticSize.X,
                                        BackgroundTransparency = 0,
                                        BackgroundColor3 = Components.WHITE_COLOR,
                                        TextColor3 = Components.BLACK_COLOR,
                                        Size = UDim2.fromScale(0, 1),

                                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            return `You Own: {use(itemAmount)}`
                                        end),

                                        [Children] = {
                                            Components.RoundUICorner(scope),
                                            Components.UIPadding(scope, {})
                                        }
                                    })
                                }
                            }),
                            Components.Frame(scope, {
                                Name = "ItemPrice",
                                AnchorPoint = Vector2.zero,
                                Position = UDim2.fromScale(0, 0.55),
                                Size = UDim2.fromScale(1, 0.5),

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

                                        Text = Fusion.Computed(scope, function()
                                            if props.Action == "Purchase" then
                                                return `<u>Price</u>`
                                            else
                                                return `<u>You Will Get</u>`
                                            end
                                        end),
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

                                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            local typedAmount = use(amount) :: number

                                            typedAmount = math.clamp(typedAmount, 1, 99)

                                            return `{HarukaLib:CommaifyNumber(use(info).Price * typedAmount)}`
                                        end),
                                    }),
                                }
                            })
                        }
                    })
                }
            }),




            Components.Frame(scope, {
                Name = "BtnsFrame",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.825),
                Size = UDim2.fromScale(0.9, 0.11),


                [Children] = {
                    Components.UIListLayout(scope, {
                        Padding = UDim.new(0.025, 0),
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    }),

                    Fusion.Computed(scope, function()
                        if props.Action == "Purchase" then
                            return ExecuteButton(scope, {
                                LayoutOrder = 2,
                                Size = UDim2.fromScale(0.45, 0.75),
                                ButtonText = "Purchase",
                                ButtonType = "Confirm",
                                ButtonClickFunc = function()
                                    props.IsPurchasing:set(false)

                                    local curAmount = Fusion.peek(amount)

                                    Events.RequestToPurchaseItem.Fire({
                                        ProductId = Fusion.peek(props.ProductId),
                                        ProductUniqueId = Fusion.peek(props.UniqueId),
                                        PurchaseAmount = curAmount
                                    })
                                end
                            })
                        else
                            return ExecuteButton(scope, {
                                LayoutOrder = 2,
                                Size = UDim2.fromScale(0.45, 0.75),
                                ButtonText = "Sell",
                                ButtonType = "Confirm",
                                ButtonClickFunc = function()
                                    props.IsPurchasing:set(false)

                                    local curAmount = Fusion.peek(amount)

                                    Events.RequestToSellItem.Fire({
                                        ItemId = Fusion.peek(props.ProductId),
                                        ItemUniqueId = Fusion.peek(props.UniqueId),
                                        SellAmount = curAmount
                                    })

                                    props.CurrentSelectedItem:set("")
                                    props.CurrentSelectedItemUniqueId:set("")
                                end
                            })
                        end
                    end),

                    ExecuteButton(scope, {
                        LayoutOrder = 1,
                        Size = UDim2.fromScale(0.45, 0.75),
                        ButtonText = "Cancel",
                        ButtonType = "Cancel",
                        ButtonClickFunc = function()
                            props.IsPurchasing:set(false)
                        end
                    })
                }
            })
        }
    })
end
