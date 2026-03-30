
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)

local Children = Fusion.Children

local CURRENCY_ICONS = AssetBook.CurrencyIcons
local MAX_PURCHASE_AMOUNT = 999

return function(scope: Fusion.Scope, props: {
    ProductId: string,
    UniqueId: string,

    IsPurchasing: Fusion.Value<boolean>,
    Action: string,

    CurrentSelectedItem: Fusion.Value<string>,
    CurrentSelectedItemUniqueId: Fusion.Value<string>,

    CurrencyId: string
})

    local info = ItemBook:GetItemInfo(props.ProductId)
    if info == nil then return nil end

    local function Value<T>(val: T) : Fusion.Value<T>
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

    elseif props.Action == "Purchase" or props.Action == "Craft" then
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

    local inputTextbox = Fusion.Hydrate(scope, Components:RefUI("AmountInput_EMarketP1_1", true))({})
    local amount = ClientLib:TrackInputTextbox({
        Scope = scope,
        TextBox = inputTextbox,

        Callback = function(amount: Fusion.UsedAs<number>)
            local function _setColor(color: Color3)
                inputTextbox.TextColor3 = color
            end
            local curAmount = tonumber(Fusion.peek(amount))

            if curAmount == nil then _setColor(Color3.fromHex('#ff6b81')) return end
            if curAmount ~= curAmount then _setColor(Color3.fromHex('#ff6b81')) return end

            if curAmount < 1 then _setColor(Color3.fromHex('#ff6b81')) return end
            if curAmount > MAX_PURCHASE_AMOUNT then _setColor(Color3.fromHex('#ff6b81')) return end

            _setColor(Color3.fromRGB(255, 255, 255))
        end
    })

    local function _commonClick()
        props.IsPurchasing:set(false)
        props.CurrentSelectedItem:set("")
        props.CurrentSelectedItemUniqueId:set("")
    end

    return Fusion.Hydrate(scope, Components:RefUI("PurchasePrompt_EMarket1_1", false, true, {
        "InnerFakeStroke"
    }))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Div_EMPP1_1", false, true))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("Title_EMPPDiv1_1"))({
                        Text = `<u>{string.upper(props.Action)}</u>`
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("ItemIcon_EMPPDiv1_1", false, false, {
                        "UICorner", "CFEmblemTexFrame"
                    }))({
                        [Fusion.Out("AbsoluteSize")] = absTextSize,

                        [Children] = {
                            Fusion.Hydrate(scope, Components:RefUI("UIGradient_EMPPDI1_1"))({
                                Color = ColorSequence.new(
                                    AssetBook.ItemTierColors[info.Tier]:Lerp(Color3.new(1, 1, 1), 0.6),
                                    AssetBook.ItemTierColors[info.Tier]
                                )
                            }),

                            Fusion.Hydrate(scope, Components:RefUI("Icon_EMPPDI1_1", true))({
                                Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return use(info).Icon
                                end)
                            }),

                            Fusion.Hydrate(scope, Components:RefUI("ItemName_EMPPDI1_1"))({
                                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return use(info).Name
                                end)
                            }),

                            Fusion.Hydrate(scope, Components:RefUI("ItemDesc_EMPPDI1_1"))({
                                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return use(info).Desc
                                end),
                                TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return use(absTextSize).Y / (79 / 18)
                                end)
                            })
                        }
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("ItemPurchaseAmount_EMPPDiv1_1", false, false, {
                        "Title"
                    }))({
                        [Children] = {
                            Fusion.Hydrate(scope, Components:RefUI("DraggerBar_EMPPDIPA1_1", false, true))({
                                [Children] = {
                                    Fusion.Hydrate(scope, Components:RefUI("DecreaseBtn_EMarketP1_1", true))({
                                        [Fusion.OnEvent("MouseButton1Click")] = function()
                                            local curAmount = Fusion.peek(amount)
                                            local nextAmount = curAmount - 1
                                            nextAmount = math.clamp(nextAmount, 1, MAX_PURCHASE_AMOUNT)

                                            amount:set(nextAmount)
                                        end
                                    }),

                                    inputTextbox,

                                    Fusion.Hydrate(scope, Components:RefUI("IncreaseBtn_EMarketP1_1", true))({
                                        [Fusion.OnEvent("MouseButton1Click")] = function()
                                            local curAmount = Fusion.peek(amount)
                                            local nextAmount = curAmount + 1
                                            nextAmount = math.clamp(nextAmount, 1, MAX_PURCHASE_AMOUNT)

                                            amount:set(nextAmount)
                                        end
                                    }),
                                }
                            })
                        }
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("ItemPurchasePrice_EMPPDiv1_1"))({
                        [Children] = {
                            Fusion.Hydrate(scope, Components:RefUI("ItemTags_EMPPDIPP1_1", false, true))({
                                [Children] = {
                                    Fusion.Hydrate(scope, Components:RefUI("YouOwned_EMPPDIPP2_1", true))({
                                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            return `You Own: {use(itemAmount)}`
                                        end)
                                    })
                                }
                            }),
                            Fusion.Hydrate(scope, Components:RefUI("ItemPrice_EMPPDIPP1_1", false, true))({
                                [Children] = {
                                    Fusion.Hydrate(scope, Components:RefUI("Title_EMarketEMPP1_1"))({
                                        Text = Fusion.Computed(scope, function()
                                            if props.Action == "Purchase" or props.Action == "Craft" then
                                                return `<u>Price</u>`
                                            else
                                                return `<u>You Will Get</u>`
                                            end
                                        end),
                                    }),

                                    Fusion.Hydrate(scope, Components:RefUI("Icon_EMarketEMPP1_1", true))({
                                        Image = CURRENCY_ICONS[props.CurrencyId],
                                    }),

                                    Fusion.Hydrate(scope, Components:RefUI("Price_EMarketEMPP1_1"))({
                                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            local typedAmount = use(amount) :: number
                                            typedAmount = math.clamp(typedAmount, 1, MAX_PURCHASE_AMOUNT)

                                            local priceType = if props.Action == "Sell" then "SellPrice" else "Price"
                                            return `{HarukaLib:AddCommaToNum(use(info)[priceType] * typedAmount)}`
                                        end),
                                    }),
                                }
                            })
                        }
                    })
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("BtnsFrame_EMPP1_1", false, true))({
                [Children] = {
                    Fusion.Computed(scope, function(_, scope: Fusion.Scope)
                        if props.Action == "Purchase" then
                            return ExecuteButton(scope, {
                                LayoutOrder = 2,
                                Size = UDim2.fromScale(0.45, 0.75),
                                ButtonText = "Purchase",
                                ButtonType = "Confirm",
                                ButtonClickFunc = function()
                                    _commonClick()
                                    local curAmount = Fusion.peek(amount)

                                    Events.BuyItem_C.Fire({
                                        ProductId = Fusion.peek(props.ProductId),
                                        ProductUniqueId = Fusion.peek(props.UniqueId),
                                        PurchaseAmount = curAmount,
                                        CurrencyId = props.CurrencyId
                                    })
                                end
                            })
                        elseif props.Action == "Sell" then
                            return ExecuteButton(scope, {
                                LayoutOrder = 2,
                                Size = UDim2.fromScale(0.45, 0.75),
                                ButtonText = "Sell",
                                ButtonType = "Confirm",
                                ButtonClickFunc = function()
                                    _commonClick()
                                    local curAmount = Fusion.peek(amount)

                                    Events.SellItem_C.Fire({
                                        ItemId = Fusion.peek(props.ProductId),
                                        ItemUniqueId = Fusion.peek(props.UniqueId),
                                        SellAmount = curAmount
                                    })
                                end
                            })
                        elseif props.Action == "Craft" then
                            return ExecuteButton(scope, {
                                LayoutOrder = 2,
                                Size = UDim2.fromScale(0.45, 0.75),
                                ButtonText = "Craft",
                                ButtonType = "Confirm",
                                ButtonClickFunc = function()
                                    _commonClick()
                                    local curAmount = Fusion.peek(amount)

                                    Events.CraftItem_C.Fire({
                                        ItemId = Fusion.peek(props.ProductId),
                                        ItemUniqueId = Fusion.peek(props.UniqueId),
                                        CraftAmount = curAmount
                                    })
                                end
                            })
                        end

                        return nil
                    end),

                    ExecuteButton(scope, {
                        LayoutOrder = 1,
                        Size = UDim2.fromScale(0.45, 0.75),
                        ButtonText = "Cancel",
                        ButtonType = "Cancel",
                        ButtonClickFunc = _commonClick
                    })
                }
            })
        }
    })
end