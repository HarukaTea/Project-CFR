
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

local StarTierSymbol = require(RepS.HarukaShared.UIAtlas.Components.StarTierSymbol)

local Children = Fusion.Children


local CURRENCY_ICONS = AssetBook.CurrencyIcons


return function(scope: Fusion.Scope, props: {
    ProductId: string,
    UniqueId: string,

    CurrentSelectedItem: Fusion.Value<string>,
    CurrentSelectedItemUniqueId: Fusion.Value<string>,

    CurrencyId: Fusion.Value<string>,
})

    local info = ItemBook:GetItemInfo(props.ProductId)
    if not info then return nil end


    local isSelecting = Fusion.Value(scope, false)



    return Components.Frame(scope, {
        Name = "Product_"..props.ProductId,
        BackgroundTransparency = 0.1,
        Size = UDim2.fromScale(0.97, 0.18),

        [Children] = {
            Components.UIAspectRatioConstraint(scope, 11.804),

            Components.UICorner(scope, { CornerRadius = UDim.new(0.1, 0) }),
            Components.ScaledUIStroke(scope, {
                Thickness = 0.035,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting) or use(props.CurrentSelectedItemUniqueId) == props.UniqueId
                end)
            }),

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if Fusion.peek(props.CurrentSelectedItemUniqueId) == props.UniqueId then
                        props.CurrentSelectedItemUniqueId:set("")
                        props.CurrentSelectedItem:set("")
                        return
                    end

                    props.CurrentSelectedItemUniqueId:set(props.UniqueId)
                    props.CurrentSelectedItem:set(props.ProductId)
                end
            }),

            Components.Frame(scope, {
                Name = "Div",
                Size = UDim2.fromScale(0.97, 0.9),

                [Children] = {
                    Components.UIListLayout(scope, {
                        Padding = UDim.new(0.015, 0),
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        FillDirection = Enum.FillDirection.Horizontal
                    }),

                    Components.IconImageLabel(scope, {
                        Size = UDim2.fromScale(0.9, 0.9),
                        Image = info.Icon
                    }),

                    Components.Frame(scope, {
                        Name = "ItemInfoAttrs",

                        [Children] = {
                            Components.Frame(scope, {
                                Name = "ItemName",
                                LayoutOrder = 1,
                                AnchorPoint = Vector2.zero,
                                Position = UDim2.fromScale(0, 0),
                                Size = UDim2.fromScale(1, 0.4),

                                [Children] = {
                                    Components.UIListLayout(scope, {
                                        Padding = UDim.new(0.005, 0),
                                        FillDirection = Enum.FillDirection.Horizontal,
                                        VerticalAlignment = Enum.VerticalAlignment.Center
                                    }),

                                    Components.TextLabel(scope, {
                                        Name = "ItemName",
                                        AutomaticSize = Enum.AutomaticSize.X,
                                        Text = info.Name,
                                        Size = UDim2.fromScale(0, 1),
                                        TextXAlignment = Enum.TextXAlignment.Left,
                                        LayoutOrder = 0,

                                        [Children] = {
                                            Components.UIPadding(scope, {
                                                PaddingTop = UDim.new(),
                                                PaddingBottom = UDim.new(),
                                                PaddingLeft = UDim.new(0, 4),
                                                PaddingRight = UDim.new(0, 9)
                                            })
                                        }
                                    }),

                                    Fusion.ForPairs(scope, table.create(info.Tier, true), function(_, scope: Fusion.Scope, index: number, _)
                                        return index, StarTierSymbol(scope, {
                                            Size = UDim2.fromScale(0.8, 0.8)
                                        })
                                    end)
                                }
                            }),
                            Components.Frame(scope, {
                                Name = "ItemTags",
                                AnchorPoint = Vector2.xAxis,
                                Position = UDim2.fromScale(0.92, 0.05),
                                Size = UDim2.fromScale(1, 0.4),

                                [Children] = {
                                    Components.UIListLayout(scope, {
                                        Padding = UDim.new(0.005, 0),
                                        FillDirection = Enum.FillDirection.Horizontal,
                                        VerticalAlignment = Enum.VerticalAlignment.Center,
                                        HorizontalAlignment = Enum.HorizontalAlignment.Right
                                    }),

                                    Components.TextLabel(scope, {
                                        Name = "ItemLevel",
                                        AutomaticSize = Enum.AutomaticSize.X,
                                        BackgroundTransparency = 0,
                                        BackgroundColor3 = Components.WHITE_COLOR,
                                        Text = `Req Lv.{info.Level}`,
                                        TextColor3 = Components.BLACK_COLOR,
                                        Size = UDim2.fromScale(0, 1),
                                        LayoutOrder = 0,

                                        Visible = info.Level > 1,

                                        [Children] = {
                                            Components.RoundUICorner(scope),
                                            Components.UIPadding(scope, {
                                                PaddingLeft = UDim.new(0, 12),
                                                PaddingRight = UDim.new(0, 12)
                                            })
                                        }
                                    }),
                                }
                            }),
                            Components.Frame(scope, {
                                Name = "ItemPrice",
                                LayoutOrder = 2,
                                AnchorPoint = Vector2.zero,
                                Position = UDim2.fromScale(0, 0.5),
                                Size = UDim2.fromScale(1, 0.45),

                                [Children] = {
                                    Components.UIListLayout(scope, {
                                        FillDirection = Enum.FillDirection.Horizontal,
                                        VerticalAlignment = Enum.VerticalAlignment.Center,
                                        Padding = UDim.new(0.02, 0)
                                    }),

                                    Components.IconImageLabel(scope, {
                                        LayoutOrder = 1,

                                        Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            return CURRENCY_ICONS[use(props.CurrencyId)]
                                        end)
                                    }),


                                    Components.TextLabel(scope, {
                                        Name = "Price",
                                        AutomaticSize = Enum.AutomaticSize.X,
                                        Text = HarukaLib:CommaifyNumber(info.Price),
                                        Size = UDim2.fromScale(0, 1),
                                        TextXAlignment = Enum.TextXAlignment.Left,
                                        LayoutOrder = 2,
                                        FontFace = Font.fromName("TitilliumWeb", Enum.FontWeight.Bold)
                                    }),
                                }
                            })
                        }
                    })
                }
            })
        }
    })
end