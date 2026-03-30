
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
local FormulaBook = require(RepS.HarukaShared.Library.FormulaBook)

local StarTierSymbol = require(RepS.HarukaShared.UIAtlas.Components.StarTierSymbol)

local Children = Fusion.Children

local ITEM_EFFECTS_ICONS = {
	CanLight = "rbxassetid://2965771738",
	CanMine = "rbxassetid://12118509077",
	CanClimb = "rbxassetid://119170658838472",

	CD = "rbxassetid://81749788783510",
	CriChance = "rbxassetid://73146024586376",
	ATK = "rbxassetid://2965862892",
	Speed = "rbxassetid://128019227796527",
	Magic = "rbxassetid://2965863231",
	MaxHealth = "rbxassetid://104142948728530",
	MaxShield = "rbxassetid://139807236835811",
	Warding = "rbxassetid://133479347120603",
	PoisonChance = "rbxassetid://137874332790885",
	BurnChance = "rbxassetid://74588474308433",
	BleedChance = "rbxassetid://101337562500575",
	FreezeChance = "rbxassetid://79241468928508",
    ShockingChance = "rbxassetid://106465902273177",
	JumpPower = "rbxassetid://89411498131129",
	Jump = "rbxassetid://89411498131129",
	Mana = "rbxassetid://12119869276",
    MaxMana = "rbxassetid://12119869276",

	Intensity = "rbxassetid://128019227796527",
	CriDMG = "rbxassetid://73146024586376",

	Focus = "rbxassetid://132943384940547",
	Combo = "rbxassetid://91123652494859",
	Stack = "rbxassetid://85379466166048",

	Luck = "rbxassetid://109627611842021"
}
local ITEM_EFFECTS_ICON_COLORS = {
	CriChance = Color3.fromHex('#ffeaa7'),
	MaxHealth = Color3.fromHex('#2ed573'),
	MaxShield = Color3.fromHex('#ffeaa7'),
	FreezeChance = Color3.fromHex('#81ecec'),
    ShockingChance = Color3.fromRGB(255, 255, 127),
    Luck = Color3.fromHex('#2ed573'),
}
local ITEM_EFFECTS_NAMES = {
	CD = "CD Time",
	CriChanceEx = "Critical Chance",
	CriDMGEx = "Critical DMG",
	ATK = "ATK",
    MaxManaEx = "Mana",
    Mana = "Mana Cost",
	SpeedEx = "Speed",
	MagicEx = "Magic",
	MaxHealthEx = "Health",
	MaxShieldEx = "Shield",
	PoisonChanceEx = "Poison Chance",
	BurnChanceEx = "Burn Chance",
	BleedChanceEx = "Bleed Chance",
	FreezeChanceEx = "Freeze Chance",
    ShockingChanceEx = "Stun Chance",
	JumpEx = "Jump",
    WardingEx = "Warding",
    LuckEx = "Luck",
    IntensityEx = "Intensity",
}
local ITEM_EFFECTS_IS_PERCENTAGE = {
	CriChanceEx = true,
	CriDMGEx = true,
	PoisonChanceEx = true,
	BurnChanceEx = true,
	BleedChanceEx = true,
	FreezeChanceEx = true,
    ShockingChanceEx = true,
}

return function (scope: Fusion.Scope, props: {
    Item: string,
    ItemUniqueId: string,
    EquippingItems: Fusion.Value<{ StringValue }>,

    Items: { IntConstrainedValue }?,
    IsMarket: boolean?,
    IsCrafting: boolean?,
})

    local absDescFrameSize = Fusion.Value(scope, Vector2.zero)

    local info = ItemBook:GetItemInfo(props.Item)
    if not info then return nil end

    local itemInfo = info

    local artifactInfo = ArtifactBook:GetArtifactInfo(info.ArtifactId)

    local itemSymbol: IntConstrainedValue = nil
    local targetContainer: { IntConstrainedValue } = {}

    if props.IsMarket then
        targetContainer = CollectionService:GetTagged("MarketProductEntity")
    elseif props.IsCrafting then
        targetContainer = CollectionService:GetTagged("CraftingProductEntity")
    else
        targetContainer = props.Items
    end
    for _, symbol in targetContainer do
        if symbol:GetAttribute("HarukaUniqueId") == props.ItemUniqueId then
            itemSymbol = symbol
            break
        end
    end
    if itemSymbol == nil then return nil end

    local isFavItem = Fusion.Value(scope, false)
    local isFav: ImageButton = nil
    if props.IsMarket or props.IsCrafting then
        --- do nothing
    else
        table.insert(scope, HarukaLib:Hydrate(itemSymbol, {
            ["Attr-IsFav"] = function(state: boolean)
                state = state or false

                isFavItem:set(state)
            end
        }))

        isFav = Fusion.Hydrate(scope, Components:RefUI("FavButton_BKID1_1", false, true))({
            [Fusion.OnEvent("MouseButton1Click")] = function()
                Events.FavOrLockItem_C.Fire({
                    ActionId = "Fav",
                    ItemSymbol = itemSymbol
                })
            end,

            [Children] = {
                Fusion.Hydrate(scope, Components:RefUI("Star_BKIDFB1_1"))({
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
        --- do nothing
    else
        table.insert(scope, HarukaLib:Hydrate(itemSymbol, {
            ["Attr-IsLocked"] = function(state: boolean)
                state = state or false

                isLockedItem:set(state)
            end
        }))

        isLocked =  Fusion.Hydrate(scope, Components:RefUI("LockedButton_BKID1_1", false, true))({
            [Fusion.OnEvent("MouseButton1Click")] = function()
                Events.FavOrLockItem_C.Fire({
                    ActionId = "Lock",
                    ItemSymbol = itemSymbol
                })
            end,

            [Children] = {
                Fusion.Hydrate(scope, Components:RefUI("Lock_BKIDLB1_1"))({
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
    itemStatExtra = ItemBook:ParseItemStat("Stat", itemStatExtra)

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
        Val: any,

        IsPotType: boolean?,
    })
        local attr, val = properties.Attr, properties.Val

        return Fusion.Hydrate(scope, Components:RefUI("CA_ItemEffect_Template_BKID1_1", false, true))({
            Name = "CCC_ItemEffect_"..attr,

            [Children] = {
                Fusion.Hydrate(scope, Components:RefUI("EffectIcon_BKIDIE1_1", true))({
                    Image = Fusion.Computed(scope, function()
                        if string.find(attr, "Can") then
                            return ITEM_EFFECTS_ICONS[attr] or AssetBook.ExtraIcons.Unknown

                        elseif string.find(attr, "Ex") or string.find(attr, "ExPower") then
                            local exPos = string.find(attr, "Ex")
                            return ITEM_EFFECTS_ICONS[string.sub(attr, 1, exPos - 1)] or AssetBook.ExtraIcons.Unknown

                        elseif attr == "ForClass" then
                            local classInfo = ClassBook[val]
                            if classInfo == nil then
                                return AssetBook.ExtraIcons.Unknown
                            end
                            return classInfo.Icon
                        else
                            return ITEM_EFFECTS_ICONS[attr] or AssetBook.ExtraIcons.Unknown
                        end
                    end),
                    ImageColor3 = Fusion.Computed(scope, function()
                        if string.find(attr, "ForClass") then
                            local classInfo = ClassBook[val]
                            if classInfo == nil then
                                return Color3.new(1, 1, 1)
                            end
                            return classInfo.Color
                        end
                        if string.find(attr, "Can") then
                            return ITEM_EFFECTS_ICON_COLORS[attr] or Color3.new(1, 1, 1)
                        end
                        if string.find(attr, "Ex") or string.find(attr, "ExPower") then
                            local exPos = string.find(attr, "Ex")
                            return ITEM_EFFECTS_ICON_COLORS[string.sub(attr, 1, exPos - 1)] or Color3.new(1, 1, 1)
                        end

                        return Color3.new(1, 1, 1)
                    end),
                }),
                Fusion.Hydrate(scope, Components:RefUI("Stat_BKIDIE1_1", true))({
                    Text = Fusion.Computed(scope, function()
                        if val == true or val == false then
                            return `<font color="#e9cc9f">Ability: </font> `..string.sub(attr, 4)

                        elseif attr == "ForClass" then
                            return `<font color="#e9cc9f">Class: </font> {val}`
                        elseif properties.IsPotType then
                            local DEFAULT_TEXT = `<font color="#e9cc9f">{ITEM_EFFECTS_NAMES[attr]}: </font> {val}{if ITEM_EFFECTS_IS_PERCENTAGE[attr] then "%" else ""}`

                            local basePot = itemInfo.StatInfoDesync[attr]
                            if basePot == nil then return DEFAULT_TEXT end

                            local maxPot = FormulaBook.ItemUpgradeCurveCal(basePot)

                            local potRatio
                            local upgradeRange = maxPot - basePot
                            if upgradeRange == 0 then return DEFAULT_TEXT end

                            potRatio = math.floor( ((val - basePot) / upgradeRange) * 100 )

                            local color = Components.RED_COLOR:ToHex()
                            if potRatio >= 30 and potRatio <= 70 then
                                color = Components.BLUE_COLOR:ToHex()
                            elseif potRatio > 70 then
                                color = Components.GREEN_COLOR:ToHex()
                            end

                            if potRatio <= 0 then return DEFAULT_TEXT end

                            return `<font color="#e9cc9f">{ITEM_EFFECTS_NAMES[attr]}: </font> {val}{if ITEM_EFFECTS_IS_PERCENTAGE[attr] then "%" else ""}   <font color="#{color}">(+{potRatio}%)</font>`
                        else
                            return `<font color="#e9cc9f">{ITEM_EFFECTS_NAMES[attr]}: </font> {val}{if ITEM_EFFECTS_IS_PERCENTAGE[attr] then "%" else ""}`
                        end
                    end)
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

        return Fusion.Hydrate(scope, Components:RefUI("B_ItemStats_AutoYTemplate_BKID1_1"))({
            Name = name,
            LayoutOrder = order,
            Text = text,
            TextColor3 = color or Color3.fromRGB(255, 255, 255),

            TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return math.clamp(use(absDescFrameSize).Y / (33 / 21), 1, 32)
            end),
            Visible = text ~= ""
        })
    end

    return Fusion.Hydrate(scope, Components:RefUI("ItemDesc_BK1_1", false, true))({
        Visible = Fusion.Computed(scope, function()
            return ItemBook:GetItemInfo(props.Item) ~= nil
        end),

        [Children] = {
            Components.PaddingFrame(scope, "AAA"),

            Fusion.Hydrate(scope, Components:RefUI("ItemName_BKID1_1", false, true))({
                [Fusion.Out("AbsoluteSize")] = absDescFrameSize,

                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("LeftOrder_BKID1_1", false, true))({
                        [Children] = {
                            Fusion.Hydrate(scope, Components:RefUI("TierIndicator_BKID1_1"))({
                                BackgroundColor3 = AssetBook.ItemTierColors[info.Tier]
                            }),
                            Fusion.Hydrate(scope, Components:RefUI("ItemName_BKID1_4"))({
                                Text = info.Name,
                            }),
                        }
                    }),
                    Fusion.Hydrate(scope, Components:RefUI("RightOrder_BKID1_1", false, true))({
                        [Children] = {
                            Fusion.Hydrate(scope, Components:RefUI("Req_BKID1_1", true))({
                                Text = `Req Lv.{info.Level}`,
                                Visible = info.Type ~= "Material"
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
                    Fusion.Hydrate(scope, Components:RefUI("A_ItemIcon_BKID1_1", false, false, {
                        "UICorner", "UIAspectRatioConstraint", "CFEmblemTexFrame"
                    }))({
                        Name = "AAA_ItemIcon",

                        [Children] = {
                            Fusion.Hydrate(scope, Components:RefUI("UIGradient_BKID1_1"))({
                                Color = ColorSequence.new(
                                    AssetBook.ItemTierColors[info.Tier]:Lerp(Color3.new(1, 1, 1), 0.6),
                                    AssetBook.ItemTierColors[info.Tier]
                                )
                            }),

                            Fusion.Hydrate(scope, Components:RefUI("Icon_BKIDIC1_1", true))({
                                Image = info.Icon
                            }),

                            Fusion.Hydrate(scope, Components:RefUI("ItemTiers_BKID1_1", false, true))({
                                [Children] = {
                                    Fusion.ForPairs(scope, table.create(info.Tier, true), function(_, scope: Fusion.Scope, index: number, _)
                                        return index, StarTierSymbol(scope, {})
                                    end)
                                }
                            }),

                            isFav, isLocked,
                        }
                    }),

                    ItemStatAutomaticY("BBB_ItemStats", 1, HarukaLib:RichText(info.Stat)),

                    Fusion.ForPairs(scope, info.ExtraStatInfoDesync, function(_, scope: Fusion.Scope, attr: string, val: any)
                        return attr, ItemEffectShowcase(scope, {
                            Attr = attr,
                            Val = val
                        })
                    end),
                    Fusion.ForPairs(scope, itemStatExtra, function(_, scope: Fusion.Scope, attr: string, val: any)
                        return attr, ItemEffectShowcase(scope, {
                            Attr = attr,
                            Val = val,

                            IsPotType = true
                        })
                    end),

                    ItemStatAutomaticY("DDD_ItemDesc", 233, HarukaLib:RichText(info.Desc), Color3.fromRGB(159, 159, 159)),

                    Fusion.Hydrate(scope, Components:RefUI("E_ArtifactTitle_BKID1_1", true))({
                        Name = "EEE_ArtifactTitle",

                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return `<u>{artifactInfo.ArtifactTitle}({use(artifactEquipped)}):</u>`
                        end),
                        Visible = Fusion.Computed(scope, function()
                            return artifactInfo.ArtifactTitle ~= nil
                        end)
                    }),

                    ItemStatAutomaticY("FFF_Artifact2PieceDesc", 235, artifactInfo.TwoPieceEff, Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return if use(artifactEquipped) >= 2 then Color3.fromRGB(154, 255, 136) else Color3.fromRGB(159, 159, 159)
                    end)),
                    ItemStatAutomaticY("GGG_Artifact3PieceDesc", 236, artifactInfo.ThreePieceEff, Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return if use(artifactEquipped) >= 3 then Color3.fromRGB(153, 255, 136) else Color3.fromRGB(159, 159, 159)
                    end)),

                    Fusion.Hydrate(scope, Components:RefUI("H_HorizontalLine_BKID1_1", true))({
                        Name = "HHH_HorizontalLine",
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("I_ItemTags_BKID1_1", false, true))({
                        Name = "III_ItemTags",

                        [Children] = {
                            Fusion.ForPairs(scope, info.TagsDesync, function(_, scope: Fusion.Scope, index: number, tag: string)
                                return index, Fusion.Hydrate(scope, Components:RefUI("Tag_Template_BKID1_1", true))({
                                    Name = tag,
                                    LayoutOrder = index,

                                    Text = Fusion.Computed(scope, function()
                                        local result = string.gsub(tag, "(%u)(%l+)", function(first, rest)
                                            return " "..string.upper(first)..string.lower(rest)
                                        end)
                                        return result
                                    end)
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