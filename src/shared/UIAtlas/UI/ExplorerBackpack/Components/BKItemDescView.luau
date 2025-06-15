--!nocheck

local CollectionService = game:GetService("CollectionService")
local RepS = game:GetService("ReplicatedStorage")


local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemLib = require(RepS.HarukaShared.Library.ItemLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    Item: string,
    ItemUniqueId: string,

    Items: table?,
    IsMarket: boolean?,
    IsCrafting: boolean?,
})

    local absDescFrameSize = Fusion.Value(scope, Vector2.zero)


    local info = ItemLib:GetItemInfo(props.Item)
    if not info then return nil end


    local itemSymbol: IntConstrainedValue = nil
    if props.IsMarket then
        for _, symbol: Instance in CollectionService:GetTagged("MarketProductEntity") do
            if symbol:GetAttribute("HarukaUniqueId") == props.ItemUniqueId then
                itemSymbol = symbol
                break
            end
        end
    elseif props.IsCrafting then
        for _, symbol: IntConstrainedValue in CollectionService:GetTagged("CraftingProductEntity") do
            if symbol:GetAttribute("HarukaUniqueId") == props.ItemUniqueId then
                itemSymbol = symbol
                break
            end
        end
    else
        for _, symbol: IntConstrainedValue in props.Items do
            if symbol:GetAttribute("HarukaUniqueId") == props.ItemUniqueId then
                itemSymbol = symbol
                break
            end
        end
    end
    if itemSymbol == nil then return nil end


    local itemStat = itemSymbol:GetAttribute("ItemStat")
    if itemStat == nil then return nil end

    local itemStatExtra = string.split(itemStat, ",")
    itemStatExtra = ItemLib:DesyncItemStat("Stat", itemStatExtra)



    local function ItemEffectShowcase(scope: Fusion.Scope, properties: {
        Attr: string,
        Val: any
    })
        local attr, val = properties.Attr, properties.Val

        return Components.Frame(scope, {
            Name = "BBB_ItemEffect_"..attr,
            Size = UDim2.fromScale(0.95, 0.17),
            LayoutOrder = 3,
            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.fromRGB(),

            [Children] = {
                Components.RoundUICorner(scope),
                Components.UIAspectRatioConstraint(scope, 9.813),

                Components.UIListLayout(scope, {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0.03, 0),
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                }),

                Components.IconImageLabel(scope, {
                    Name = "EffectIcon",

                    Image = Fusion.Computed(scope, function()
                        if string.find(attr, "Can") then
                            return AssetBook.ItemEffectIcons[attr] or AssetBook.ExtraIcons.Unknown

                        elseif string.find(attr, "Ex") or string.find(attr, "ExPower") then
                            local exPos = string.find(attr, "Ex")
                            return AssetBook.ItemEffectIcons[string.sub(attr, 1, exPos - 1)] or AssetBook.ExtraIcons.Unknown

                        elseif attr == "ForClass" then
                            local classInfo = ClassBook[val]
                            if classInfo == nil then
                                return AssetBook.ExtraIcons.Unknown
                            end

                            return classInfo.Icon

                        elseif attr == "ForVariant" then
                            return AssetBook.ItemEffectIcons[val] or AssetBook.ExtraIcons.Unknown
                        else
                            return AssetBook.ItemEffectIcons[attr] or AssetBook.ExtraIcons.Unknown
                        end
                    end),
                    ImageColor3 = Fusion.Computed(scope, function()
                        if attr == "ForClass" then
                            local classInfo = ClassBook[val]
                            if classInfo == nil then
                                return Color3.new(1, 1, 1)
                            end

                            return classInfo.Color

                        elseif attr == "ForVariant" then
                            return AssetBook.ItemEffectIconColors[val] or Color3.new(1, 1, 1)

                        elseif string.find(attr, "Can") then
                            return AssetBook.ItemEffectIconColors[attr] or Color3.new(1, 1, 1)

                        elseif string.find(attr, "Ex") or string.find(attr, "ExPower") then
                            local exPos = string.find(attr, "Ex")
                            return AssetBook.ItemEffectIconColors[string.sub(attr, 1, exPos - 1)] or Color3.new(1, 1, 1)
                        else
                            return Color3.new(1, 1, 1)
                        end
                    end),
                }),
                Components.TextLabel(scope, {
                    Name = "Stat",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    RichText = true,

                    Text = Fusion.Computed(scope, function()
                        if val == true or val == false then
                            return `<font color="#81ecec">Ability: </font> `..string.sub(attr, 4)

                        elseif attr == "ForClass" then
                            return `<font color="#81ecec">Class: </font> {val}`

                        elseif attr == "ForVariant" then
                            return `<font color="#81ecec">Variant: </font> {val}`
                        else
                            return `<font color="#81ecec">{AssetBook.ItemEffectNames[attr]}: </font> {val}{if AssetBook.ItemEffectIsPercentage[attr] then "%" else ""}`
                        end
                    end),

                    [Children] = {
                        Components.UIPadding(scope, {
                            PaddingTop = UDim.new(0.16, 0),
                            PaddingBottom = UDim.new(0.16, 0),
                            PaddingLeft = UDim.new(0, 0),
                            PaddingRight = UDim.new(0, 0)
                        })
                    }
                })
            }
        })
    end



    return Components.Frame(scope, {
        Name = "ItemDesc",
        BackgroundTransparency = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.fromScale(0.98, 0.8),
        Size = UDim2.fromScale(0.28, 7),

        Visible = Fusion.Computed(scope, function()
            return ItemLib:GetItemInfo(props.Item) ~= nil
        end),

        [Children] = {
            Components.UICorner(scope, { CornerRadius = UDim.new(0.015, 0) }),

            Components.UIStroke(scope, {
                Thickness = 6,
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

                    Components.UIListLayout(scope, {
                        Padding = UDim.new(0.05, 0),
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    }),

                    Components.Frame(scope, {
                        Name = "TierIndicator",
                        Size = UDim2.fromScale(0.02, 0.65),

                        BackgroundTransparency = 0,
                        BackgroundColor3 = AssetBook.TierColorsType2[info.Tier]
                    }),
                    Components.TextLabel(scope, {
                        Name = "ItemName",
                        Size = UDim2.fromScale(0.7, 0.7),
                        TextXAlignment = Enum.TextXAlignment.Left,

                        Text = info.Name,

                        [Fusion.Out("AbsoluteSize")] = absDescFrameSize,
                    }),
                    Components.Frame(scope, {
                        Name = "ItemLevel",
                        Size = UDim2.fromScale(0.2, 1),

                        [Children] = {
                            Components.UIListLayout(scope, {
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                            }),

                            Components.TextLabel(scope, {
                                Name = "Req",
                                BackgroundColor3 = Components.WHITE_COLOR,
                                BackgroundTransparency = 0,
                                Size = UDim2.fromScale(1.3, 0.7),
                                TextColor3 = Components.BLACK_COLOR,

                                Text = `Req Lv.{itemSymbol:GetAttribute("Level")}`,
                                Visible = itemSymbol:GetAttribute("Level") > 1 and info.Type ~= "Material",

                                [Children] = {
                                    Components.RoundUICorner(scope),
                                    Components.UIPadding(scope, {})
                                }
                            })
                        }
                    })
                }
            }),

            Components.Frame(scope, {
                Name = "ItemIcon",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0,
                Size = UDim2.fromScale(0.9, 0.25),
                LayoutOrder = 3,
                ClipsDescendants = true,

                [Children] = {
                    Components.UIAspectRatioConstraint(scope, 3.637),

                    Components.UICorner(scope, { CornerRadius = UDim.new(0.1, 0) }),

                    Components.UIGradient(scope, {
                        Color = ColorSequence.new(
                            AssetBook.TierColorsType2[info.Tier],
                            AssetBook.TierColorsType2[info.Tier]:Lerp(Color3.new(), 0.5)
                        ),
                        Rotation = 60,
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.75),
                            NumberSequenceKeypoint.new(1, 0.5)
                        })
                    }),

                    Components.IconImageLabel(scope, {
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.fromScale(0.05, 0.5),
                        Size = UDim2.fromScale(0.17, 0.17),
                        SizeConstraint = Enum.SizeConstraint.RelativeXX,

                        Image = info.Icon
                    }),
                    Components.IconImageLabel(scope, {
                        Name = "BigIcon",
                        BackgroundTransparency = 0.85,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.5, 0.5),
                        SizeConstraint = Enum.SizeConstraint.RelativeXX,

                        Image = info.Icon,
                        ImageTransparency = 0.94,
                        ZIndex = 0
                    }),

                    Components.TextLabel(scope, {
                        Name = "ItemType",
                        Position = UDim2.fromScale(0.5, 0.17),
                        Size = UDim2.fromScale(0.45, 0.35),
                        FontFace = Font.fromName("TitilliumWeb", Enum.FontWeight.Bold),
                        TextXAlignment = Enum.TextXAlignment.Right,

                        Text = info.Type,

                        [Children] = {
                            Components.TextUIStroke(scope, { Thickness = 2 })
                        }
                    }),
                    Components.TextLabel(scope, {
                        Name = "ItemTier",
                        Position = UDim2.fromScale(0.5, 0.552),
                        Size = UDim2.fromScale(0.45, 0.25),
                        FontFace = Font.fromName("TitilliumWeb", Enum.FontWeight.Bold),
                        TextXAlignment = Enum.TextXAlignment.Right,

                        Text = Fusion.Computed(scope, function()
                            local tier = { "I", "II", "III", "IV", "V" }

                            return "TIER "..tier[info.Tier]
                        end),

                        [Children] = {
                            Components.TextUIStroke(scope, { Thickness = 2 })
                        }
                    }),
                }
            }),

            Components.ScrollingFrame(scope, {
                Name = "ItemInfo",
                LayoutOrder = 4,
                Size = UDim2.fromScale(0.9, 0.525),

                [Children] = {
                    Components.TextLabel(scope, {
                        Name = "AAA_ItemStats",
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.fromScale(0.97, 0),
                        LayoutOrder = 1,
                        TextScaled = false,
                        TextWrapped = true,
                        RichText = true,
                        LineHeight = 1.2,

                        Text = HarukaLib:RichTextify(info.Stat),
                        TextXAlignment = Enum.TextXAlignment.Left,

                        TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return math.clamp(use(absDescFrameSize).Y / 1.1, 1, 33)
                        end),
                        Visible = Fusion.Computed(scope, function()
                            return info.Stat ~= ""
                        end)
                    }),


                    Fusion.ForPairs(scope, info.ExtraStatInfoDesync, function(_, scope: Fusion.Scope, attr: string, val: any)
                        return attr, ItemEffectShowcase(scope, {
                            Attr = attr,
                            Val = val
                        })
                    end),
                    Fusion.ForPairs(scope, itemStatExtra, function(_, scope: Fusion.Scope, attr: string, val: any)
                        return attr, ItemEffectShowcase(scope, {
                            Attr = attr,
                            Val = val
                        })
                    end),



                    Components.TextLabel(scope, {
                        Name = "CCC_ItemDesc",
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.fromScale(0.97, 0),
                        LayoutOrder = 233,
                        TextScaled = false,
                        TextWrapped = true,
                        RichText = true,
                        LineHeight = 1.2,

                        Text = HarukaLib:RichTextify(info.Desc),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextColor3 = Color3.fromRGB(159, 159, 159),

                        TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return math.clamp(use(absDescFrameSize).Y / 1.1, 1, 33)
                        end)
                    }),


                    Components.Frame(scope, {
                        Name = "DDD_HorizontalLine",
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BackgroundTransparency = 0.5,
                        Size = UDim2.fromScale(1, 0.015),
                        LayoutOrder = 234,

                        [Children] = {
                            Components.UIAspectRatioConstraint(scope, 117.07)
                        }
                    }),

                    Components.Frame(scope, {
                        Name = "EEE_ItemTags",
                        Size = UDim2.fromScale(1, 0.12),
                        LayoutOrder = 235,

                        [Children] = {
                            Components.UIAspectRatioConstraint(scope, 13.777),

                            Components.UIListLayout(scope, {
                                Padding = UDim.new(0.03, 0),
                                FillDirection = Enum.FillDirection.Horizontal,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                            }),

                            Fusion.ForPairs(scope, info.TagsDesync, function(_, scope: Fusion.Scope, index: number, tag: string)
                                return index, Components.TextLabel(scope, {
                                    Name = "Tag",
                                    LayoutOrder = index,
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    Size = UDim2.fromScale(0, 1),
                                    BackgroundTransparency = 0,
                                    BackgroundColor3 = Components.WHITE_COLOR,
                                    TextColor3 = Components.BLACK_COLOR,

                                    Text = Fusion.Computed(scope, function()
                                        local result = string.gsub(tag, "(%u)(%l+)", function(first, rest)
                                            return " "..string.upper(first)..string.lower(rest)
                                        end)
                                        return result
                                    end),

                                    [Children] = {
                                        Components.RoundUICorner(scope),
                                        Components.UIPadding(scope, {
                                            PaddingLeft = UDim.new(0, 3),
                                            PaddingRight = UDim.new(0, 3)
                                        })
                                    }
                                })
                            end)
                        }
                    })
                }
            }, {
                Padding = UDim.new(0, 10),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.Name
            })
        }
    })
end
