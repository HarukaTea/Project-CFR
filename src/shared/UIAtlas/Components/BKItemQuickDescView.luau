
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

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

    return Fusion.Hydrate(scope, Components:RefUI("ItemQuickDesc_ECraft1_1", false, true))({
        Visible = Fusion.Computed(scope, function()
            return ItemBook:GetItemInfo(props.Item) ~= nil
        end),

        [Children] = {
            Components.PaddingFrame(scope, "AAA"),

            Fusion.Hydrate(scope, Components:RefUI("ItemName_IQD1_1", false, true))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("LeftOrder_IQD1_2", false, true))({
                        [Children] = {
                            Fusion.Hydrate(scope, Components:RefUI("TierIndicator_IQD1_3"))({
                                BackgroundColor3 = AssetBook.ItemTierColors[info.Tier]
                            }),

                            Fusion.Hydrate(scope, Components:RefUI("ItemName_IQD1_3"))({
                                Text = info.Name,
                            })
                        }
                    }),
                    Fusion.Hydrate(scope, Components:RefUI("RightOrder_IQD1_2", false, true))({
                        [Children] = {
                            Fusion.Hydrate(scope, Components:RefUI("Close_Filter1_1"))({
                                Size = UDim2.fromScale(1.4, 1.4),

                                [Children] = {
                                    Fusion.Hydrate(scope, Components:RefUI("Icon_FilterClose1_1"))({
                                        ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            return if use(isSelectingClose) then Color3.fromRGB(255, 255, 0) else Color3.new(1, 1, 1)
                                        end)
                                    }),

                                    Components.HoverImageButton(scope, {
                                        Components.ConnectSelectEvents(isSelectingClose),

                                        [Fusion.OnEvent("MouseButton1Click")] = function()
                                            props.IsViewingVal:set(false)
                                            props.ItemVal:set("")
                                        end
                                    })
                                }
                            }),
                        }
                    }),
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("ItemInfo_IQDQ_1", false, true, {
                "HorizontalLine"
            }))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("ItemIcon_IQDQ2_1", false, false, {
                        "UICorner", "CFEmblemTexFrame"
                    }))({
                        [Children] = {
                            Fusion.Hydrate(scope, Components:RefUI("UIGradient_IQDQ2_1"))({
                                Color = ColorSequence.new(
                                    AssetBook.ItemTierColors[info.Tier]:Lerp(Color3.new(1, 1, 1), 0.6),
                                    AssetBook.ItemTierColors[info.Tier]
                                )
                            }),

                            Fusion.Hydrate(scope, Components:RefUI("Icon_IQDQ2_1", true))({
                                Image = info.Icon
                            }),

                            Fusion.Hydrate(scope, Components:RefUI("ItemTiers_IQDQ2_1", false, true))({
                                [Children] = {
                                    Fusion.ForPairs(scope, table.create(info.Tier, true), function(_, scope: Fusion.Scope, index: number, _)
                                        return index, StarTierSymbol(scope, {})
                                    end)
                                }
                            })
                        }
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("ItemObtainMethod_IQDQ2_1"))({
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