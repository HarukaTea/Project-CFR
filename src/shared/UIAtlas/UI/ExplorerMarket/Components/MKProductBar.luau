
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

    return Fusion.Hydrate(scope, Components:RefUI("ProductTemplate_EMarket1_1", false, false, {
        "UICorner", "UIAspectRatioConstraint"
    }))({
        Name = "Product_"..props.ProductId,

        [Children] = {
            Components.ScaledUIStroke(scope, {
                Thickness = 0.035,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting) or use(props.CurrentSelectedItemUniqueId) == props.UniqueId
                end)
            }),

            Components.HoverImageButton(scope, {
                Components.ConnectSelectEvents(isSelecting),

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

            Fusion.Hydrate(scope, Components:RefUI("Div_EMarketProduct1_1", false, true))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("Icon_EMarketProduct2_1", true))({
                        Image = info.Icon
                    }),

                    Components.Frame(scope, {
                        Name = "ItemInfoAttrs",

                        [Children] = {
                            Fusion.Hydrate(scope, Components:RefUI("ItemName_EMPIA1_1", false, true))({
                                [Children] = {
                                    Fusion.Hydrate(scope, Components:RefUI("ItemName_EMPIA2_1", true))({
                                        Text = info.Name
                                    }),

                                    Fusion.ForPairs(scope, table.create(info.Tier, true), function(_, scope: Fusion.Scope, index: number, _)
                                        return index, StarTierSymbol(scope, {
                                            Size = UDim2.fromScale(0.8, 0.8),
                                            LayoutOrder = 233 + index,
                                        })
                                    end)
                                }
                            }),
                            Fusion.Hydrate(scope, Components:RefUI("ItemTags_EMPIA1_1", false, true))({
                                [Children] = {
                                    Fusion.Hydrate(scope, Components:RefUI("ItemLevel_EMPIA2_1", true))({
                                        Text = `Req Lv.{info.Level}`,
                                        Visible = info.Level > 1
                                    }),
                                }
                            }),
                            Fusion.Hydrate(scope, Components:RefUI("ItemPrice_EMPIA1_1", false, true))({
                                [Children] = {
                                    Components.IconImageLabel(scope, {
                                        LayoutOrder = 1,
                                        Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            return CURRENCY_ICONS[use(props.CurrencyId)]
                                        end)
                                    }),

                                    Fusion.Hydrate(scope, Components:RefUI("Price_EMPIA2_1"))({
                                        Text = HarukaLib:AddCommaToNum(info.Price)
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