
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local MKProductBar = require(script.Components.MKProductBar)
local MKPurchasePrompt = require(RepS.HarukaShared.UIAtlas.Components.MKPurchasePrompt)
local BottombarEcoSlot = require(RepS.HarukaShared.UIAtlas.Components.BottombarEcoSlot)

local BKItemDescView = require(RepS.HarukaShared.UIAtlas.Components.BKItemDescView)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)
local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)
local FakeTopBGTex = require(RepS.HarukaShared.UIAtlas.Components.FakeTopBGTex)

local Children = Fusion.Children

local Pinia = require(script.Pinia)

return function (plr: Player)
    local self = {} :: Pinia.Self

    ClientLib:InitUIFramework(self, plr, "ExplorerMarket")

    Pinia(self)

    local scope = self.scope :: Fusion.Scope

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerMarket",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("CenterLeft_EMarket1_1"))({
                Interactable = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(self.IsPurchasing)
                end),

                [Children] = {
                    Components.ScrollingFrame(scope, {
                        Name = "Products",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.97, 0.95),
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                        ClipsDescendants = false,

                        [Children] = {
                            Fusion.ForPairs(scope, self.Products, function(_, scope: Fusion.Scope, index: number, itemInfo: {
                                ProductId: string,
                                ProductUniqueId: string,
                            })
                                return index, MKProductBar(scope, {
                                    ProductId = itemInfo.ProductId,
                                    UniqueId = itemInfo.ProductUniqueId,

                                    CurrentSelectedItem = self.CurrentSelectedItem,
                                    CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,

                                    CurrencyId = self.CurrencyUsing
                                })
                            end)
                        }
                    }, {
                        Padding = UDim.new(0, 10),
                    }),
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("Center2_EMarket1_1", false, true))({
                Interactable = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(self.IsPurchasing)
                end),

                [Children] = {
                    Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                        return BKItemDescView(scope, {
                            Item = use(self.CurrentSelectedItem),
                            ItemUniqueId = use(self.CurrentSelectedItemUniqueId),
                            EquippingItems = self.EquippingItems,
                            IsMarket = true
                        })
                    end),
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("ShadowOverlay2_BK1_1"))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(self.IsPurchasing)
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("Top2_BK1_1", false, true))({
                [Children] = {
                    CloseTab(scope, {
                        ViewShownValue = self.IsUIShown
                    }),
                }
            }),
        }

    }, {
        FullProps = {
            BackgroundTransparency = 0.3,
            ZIndex = 0
        },

        BottomChildren = {
            Fusion.Hydrate(scope, Components:RefUI("RSideBtns_BK1_1", false, true))({
                Interactable = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(self.IsPurchasing)
                end),

                [Children] = {
                    Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                        local curItem = use(self.CurrentSelectedItem) :: string
                        if curItem == "" then return nil end

                        return ExecuteButton(scope, {
                            Size = UDim2.fromScale(0.15, 0.7),
                            ButtonText = "Purchase",
                            ButtonType = "Confirm",
                            ButtonClickFunc = function()
                                self.IsPurchasing:set(true)
                            end
                        })
                    end),
                }
            })
        },

        TopProps = {
            Position = UDim2.fromScale(0.5, 0.02)
        },
        TopChildren = {
            Fusion.Hydrate(scope, Components:RefUI("Economy_EMarket1_1", false, true))({
                Interactable = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(self.IsPurchasing)
                end),

                [Children] = {
                    Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                        local currency = use(self.CurrencyUsing)

                        return BottombarEcoSlot(scope, {
                            Currency = currency,
                            Index = 1,

                            CurrencyVal = self.Currency[currency]
                        })
                    end)
                }
            }),

            FakeTopBGTex(scope)
        },

        CenterProps = {
            ZIndex = 10
        },
        CenterChildren = {
            Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                if not use(self.IsPurchasing) then return nil end

                local currencyId = use(self.CurrencyUsing)

                return MKPurchasePrompt(scope, {
                    ProductId = use(self.CurrentSelectedItem),
                    UniqueId = use(self.CurrentSelectedItemUniqueId),

                    IsPurchasing = self.IsPurchasing,
                    Action = "Purchase",

                    CurrentSelectedItem = self.CurrentSelectedItem,
                    CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,

                    CurrencyId = currencyId,
                })
            end)
        }
    })
    self.UI = UI

    return function ()
        Fusion.doCleanup(scope)
    end
end