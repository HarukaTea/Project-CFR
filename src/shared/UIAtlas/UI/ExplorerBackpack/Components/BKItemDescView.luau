--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local CollectionService = game:GetService("CollectionService")
local RepS = game:GetService("ReplicatedStorage")

local ArtifactBook = require(RepS.HarukaShared.Library.ArtifactBook)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Events = require(RepS.HarukaShared.Library.Events)
local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local CFEmblemTex = require(RepS.HarukaShared.UIAtlas.Components.CFEmblemTex)
local StarTierSymbol = require(RepS.HarukaShared.UIAtlas.Components.StarTierSymbol)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    Item: string,
    ItemUniqueId: string,
    EquippingItems: Fusion.Value<{ StringValue }>,

    Items: { any }?,
    IsMarket: boolean?,
    IsCrafting: boolean?,
})

    local absDescFrameSize = Fusion.Value(scope, Vector2.zero)


    local info = ItemBook:GetItemInfo(props.Item)
    if not info then return nil end


    local artifactInfo = ArtifactBook:GetArtifactInfo(info.ArtifactId)


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
        local items = props.Items :: { IntConstrainedValue }

        for _, symbol: IntConstrainedValue in items do
            if symbol:GetAttribute("HarukaUniqueId") == props.ItemUniqueId then
                itemSymbol = symbol
                break
            end
        end
    end
    if itemSymbol == nil then return nil end


    local isFavItem = Fusion.Value(scope, false)
    local isFav: ImageButton = nil
    if props.IsMarket or props.IsCrafting then
    else
        table.insert(scope, HarukaLib:Hydrate(itemSymbol, {
            ["Attr-IsFav"] = function(state: boolean)
                state = state or false

                isFavItem:set(state)
            end
        }))

        isFav =  Components.HoverImageButton(scope, {
            Name = "FavButton",
            AnchorPoint = Vector2.zero,
            Position = UDim2.fromScale(0.05, 0.1),
            Size = UDim2.fromScale(0.1, 0.1),
            SizeConstraint = Enum.SizeConstraint.RelativeXX,
            BackgroundColor3 = Color3.fromRGB(),
            BackgroundTransparency = 0,

            [Fusion.OnEvent("MouseButton1Click")] = function()
                Events.RequestToFavItem.Fire({
                    ItemSymbol = itemSymbol
                })
            end,

            [Children] = {
                Components.RoundUICorner(scope),
                Components.ImageLabel(scope, {
                    Name = "Star",
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromScale(0.7, 0.7),
                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                    Image = "rbxassetid://114302766654339",

                    ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return if use(isFavItem) then Color3.fromRGB(255, 204, 50) else Color3.fromRGB(159, 159, 159)
                    end)
                })
            }
        })
    end


    local isLockedItem = Fusion.Value(scope, false)
    local isLocked: ImageButton = nil
    if props.IsMarket or props.IsCrafting then
    else
        table.insert(scope, HarukaLib:Hydrate(itemSymbol, {
            ["Attr-IsLocked"] = function(state: boolean)
                state = state or false

                isLockedItem:set(state)
            end
        }))

        isLocked =  Components.HoverImageButton(scope, {
            Name = "LockedButton",
            AnchorPoint = Vector2.zero,
            Position = UDim2.fromScale(0.175, 0.1),
            Size = UDim2.fromScale(0.1, 0.1),
            SizeConstraint = Enum.SizeConstraint.RelativeXX,
            BackgroundColor3 = Color3.fromRGB(),
            BackgroundTransparency = 0,

            [Fusion.OnEvent("MouseButton1Click")] = function()
                Events.RequestToLockItem.Fire({
                    ItemSymbol = itemSymbol
                })
            end,

            [Children] = {
                Components.RoundUICorner(scope),
                Components.ImageLabel(scope, {
                    Name = "Lock",
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromScale(0.7, 0.7),
                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                    Image = "rbxassetid://118831261287451",

                    ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return if use(isLockedItem) then Color3.fromHex('#d63031') else Color3.fromRGB(159, 159, 159)
                    end)
                })
            }
        })
    end


    local itemStat = itemSymbol:GetAttribute("ItemStat")
    if itemStat == nil then return nil end

    local itemStatExtra = string.split(itemStat, ",")
    itemStatExtra = ItemBook:DesyncItemStat("Stat", itemStatExtra)



    local artifactEquipped = Fusion.Value(scope, 0)
    local equippingObserver = Fusion.Observer(scope, props.EquippingItems)
    equippingObserver:onBind(function()
        local amount = 0
        if not artifactInfo then return end

        for _, equipping: StringValue in Fusion.peek(props.EquippingItems) do
            local thatItemInfo = ItemBook:GetItemInfo(equipping.Value)
            if not thatItemInfo then continue end

            if thatItemInfo.ArtifactId == info.ArtifactId then
                amount += 1
            end
        end

        artifactEquipped:set(amount)
    end)



    local function ItemEffectShowcase(scope: Fusion.Scope, properties: {
        Attr: string,
        Val: any
    })
        local attr, val = properties.Attr, properties.Val

        return Components.Frame(scope, {
            Name = "CCC_ItemEffect_"..attr,
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
                    Size = UDim2.fromScale(0.8, 1),

                    Text = Fusion.Computed(scope, function()
                        if val == true or val == false then
                            return `<font color="#e9cc9f">Ability: </font> `..string.sub(attr, 4)

                        elseif attr == "ForClass" then
                            return `<font color="#e9cc9f">Class: </font> {val}`

                        elseif attr == "ForVariant" then
                            return `<font color="#e9cc9f">Variant: </font> {val}`
                        else
                            return `<font color="#e9cc9f">{AssetBook.ItemEffectNames[attr]}: </font> {val}{if AssetBook.ItemEffectIsPercentage[attr] then "%" else ""}`
                        end
                    end),

                    [Children] = {
                        Components.UIPadding(scope, {
                            PaddingTop = UDim.new(0.14, 0),
                            PaddingBottom = UDim.new(0.14, 0),
                            PaddingLeft = UDim.new(0, 0),
                            PaddingRight = UDim.new(0, 0)
                        })
                    }
                })
            }
        })
    end
    local function ItemStatAutomaticY(name: string, order: number, text: string, color: Color3 | Fusion.Computed<Color3>?)
        text = text or ""

        if string.find(name, "2PieceDesc") and text ~= "" then
            text = "- 2 Piece: "..text
        end
        if string.find(name, "3PieceDesc") and text ~= "" then
            text = "- 3 Piece: "..text
        end

        return Components.TextLabel(scope, {
            Name = name,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.fromScale(0.95, 0),
            LayoutOrder = order,
            TextScaled = false,
            TextWrapped = true,
            RichText = true,
            LineHeight = 1.2,

            Text = text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = color or Color3.fromRGB(255, 255, 255),

            TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return math.clamp(use(absDescFrameSize).Y / (33 / 21), 1, 32)
            end),
            Visible = text ~= ""
        })
    end



    return Components.Frame(scope, {
        Name = "ItemDesc",
        BackgroundTransparency = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.fromScale(0.98, 0.8),
        Size = UDim2.fromScale(0.28, 7),

        Visible = Fusion.Computed(scope, function()
            return ItemBook:GetItemInfo(props.Item) ~= nil
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

                [Fusion.Out("AbsoluteSize")] = absDescFrameSize,

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

                        [Children] = {
                            Components.UIListLayout(scope, {
                                Padding = UDim.new(0.05, 0),
                                FillDirection = Enum.FillDirection.Horizontal,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                            }),

                            Components.TextLabel(scope, {
                                Name = "Req",
                                AutomaticSize = Enum.AutomaticSize.X,
                                BackgroundColor3 = Components.WHITE_COLOR,
                                BackgroundTransparency = 0,
                                Size = UDim2.fromScale(0, 0.7),
                                TextColor3 = Components.BLACK_COLOR,

                                Text = `Req Lv.{info.Level}`,
                                Visible = info.Type ~= "Material",

                                [Children] = {
                                    Components.RoundUICorner(scope),
                                    Components.UIPadding(scope, {
                                        PaddingRight = UDim.new(0, 0),
                                        PaddingLeft = UDim.new(0, 0)
                                    })
                                }
                            })
                        }
                    }),
                }
            }),

            Components.ScrollingFrame(scope, {
                Name = "ItemInfo",
                LayoutOrder = 4,
                Size = UDim2.fromScale(0.9, 0.8),

                [Children] = {
                    Components.Frame(scope, {
                        Name = "AAA_ItemIcon",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0,
                        Size = UDim2.fromScale(1, 0.3),
                        LayoutOrder = 0,
                        ClipsDescendants = true,

                        [Children] = {
                            Components.UIAspectRatioConstraint(scope, 3.844),
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

                                    Fusion.ForValues(scope, table.create(info.Tier, true), function(_, scope: Fusion.Scope, _)
                                        return StarTierSymbol(scope, {})
                                    end)
                                }
                            }),

                            isFav, isLocked,

                            CFEmblemTex(scope, {
                                Transparency = 0.91,
                                Position = UDim2.fromScale(0.3, 0.5)
                            })
                        }
                    }),


                    ItemStatAutomaticY("BBB_ItemStats", 1, HarukaLib:RichTextify(info.Stat)),

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

                    ItemStatAutomaticY("DDD_ItemDesc", 233, HarukaLib:RichTextify(info.Desc), Color3.fromRGB(159, 159, 159)),


                    Components.TextLabel(scope, {
                        Name = "EEE_ArtifactTitle",
                        Size = UDim2.fromScale(0.95, 0.125),
                        LayoutOrder = 234,
                        RichText = true,
                        TextXAlignment = Enum.TextXAlignment.Left,

                        TextColor3 = Color3.fromRGB(153, 255, 136),

                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return `<u>{artifactInfo.ArtifactTitle}({use(artifactEquipped)}):</u>`
                        end),
                        Visible = Fusion.Computed(scope, function()
                            return artifactInfo.ArtifactTitle ~= nil
                        end),

                        [Children] = {
                            Components.UIAspectRatioConstraint(scope, 13.346)
                        }
                    }),

                    ItemStatAutomaticY("FFF_Artifact2PieceDesc", 235, artifactInfo.TwoPieceEff, Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return if use(artifactEquipped) >= 2 then Color3.fromRGB(154, 255, 136) else Color3.fromRGB(159, 159, 159)
                    end)),
                    ItemStatAutomaticY("GGG_Artifact3PieceDesc", 236, artifactInfo.ThreePieceEff, Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return if use(artifactEquipped) >= 3 then Color3.fromRGB(153, 255, 136) else Color3.fromRGB(159, 159, 159)
                    end)),



                    Components.Frame(scope, {
                        Name = "HHH_HorizontalLine",
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BackgroundTransparency = 0.5,
                        Size = UDim2.fromScale(1, 0.015),
                        LayoutOrder = 333,

                        [Children] = {
                            Components.UIAspectRatioConstraint(scope, 117.07)
                        }
                    }),

                    Components.Frame(scope, {
                        Name = "III_ItemTags",
                        Size = UDim2.fromScale(0.95, 0.12),
                        LayoutOrder = 334,

                        [Children] = {
                            Components.UIAspectRatioConstraint(scope, 13.902),

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