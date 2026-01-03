
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)


local MKProductBar = require(script.Components.MKProductBar)
local MKPurchasePrompt = require(RepS.HarukaShared.UIAtlas.Components.MKPurchasePrompt)
local TopbarCategoryBtn = require(RepS.HarukaShared.UIAtlas.Components.TopbarCategoryBtn)
local BottombarEcoSlot = require(RepS.HarukaShared.UIAtlas.Components.BottombarEcoSlot)
local BKItemSlot = require(RepS.HarukaShared.UIAtlas.Components.BKItemSlot)

local BKItemDescView = require(RepS.HarukaShared.UIAtlas.Components.BKItemDescView)
local BKItemFilterView = require(RepS.HarukaShared.UIAtlas.Components.BKItemFilterView)
local BottombarOptionBtn = require(RepS.HarukaShared.UIAtlas.Components.BottombarOptionBtn)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)
local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)
local FakeTopBGTex = require(RepS.HarukaShared.UIAtlas.Components.FakeTopBGTex)

local Children = Fusion.Children


local Pinia = require(script.Pinia)

return function (plr: Player)
    local self = {} :: Pinia.Self

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope


    Pinia(self)


    if plr.PlayerGui:FindFirstChild("ExplorerMarket") then
        plr.PlayerGui.ExplorerMarket:Destroy()
    end


    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerMarket",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end),

        [Children] = {
            Components.Frame(scope, {
                Name = "CenterLeft",
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0.018, 0.573),
                Size = UDim2.fromScale(0.667, 0.786),
                ClipsDescendants = true,

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
                            Fusion.ForValues(scope, self.Products, function(_, scope: Fusion.Scope, itemInfo: {
                                ProductId: string,
                                ProductUniqueId: string,
                            })
                                return MKProductBar(scope, {
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


            Components.Frame(scope, {
                Name = "Center_ZIndex2",
                Size = UDim2.fromScale(1, 0.1),

                Interactable = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(self.IsPurchasing)
                end),

                [Children] = {
                    Components.UIAspectRatioConstraint(scope),

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

            Components.Frame(scope, {
                Name = "ShadowOverlay2",
                BackgroundTransparency = 0.3,
                ZIndex = 3,
                Interactable = false,
                Active = false,

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(self.IsPurchasing)
                end),
            }),

            Components.HarukaFrame(scope, {
                Name = "Top2",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.02),
                ZIndex = 10,

                Interactable = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(self.IsPurchasing)
                end),

                [Children] = {
                    CloseTab(scope, {
                        ViewShownValue = self.IsUIShown
                    }),
                }
            })
        }

    }, {
        FullProps = {
            BackgroundTransparency = 0.3,
            ZIndex = 0
        },


        BottomProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "RSideBtns",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, -0.1),
                    Size = UDim2.fromScale(0.96, 1),

                    Interactable = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return not use(self.IsPurchasing)
                    end),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Right,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            Padding = UDim.new(0.01, 0),
                        }),


                        Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                            local curItem = use(self.CurrentSelectedItem) :: string

                            if curItem ~= "" then
                                return ExecuteButton(scope, {
                                    Size = UDim2.fromScale(0.15, 0.7),
                                    ButtonText = "Purchase",
                                    ButtonType = "Confirm",
                                    ButtonClickFunc = function()
                                        self.IsPurchasing:set(true)
                                    end
                                })
                            else
                                return nil
                            end
                        end),
                    }
                })
            }
        },

        TopProps = {
            Position = UDim2.fromScale(0.5, 0.02),

            [Children] = {
                Components.Frame(scope, {
                    Name = "Economy",
                    Size = UDim2.fromScale(0.82, 1),

                    Interactable = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return not use(self.IsPurchasing)
                    end),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Right,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            Padding = UDim.new(0.015, 0),
                        }),

                        Fusion.ForPairs(scope, table.create(1, true), function(use: Fusion.Use, scope: Fusion.Scope, index: number, _)
                            local currency = use(self.CurrencyUsing)

                            return index, BottombarEcoSlot(scope, {
                                Currency = currency,
                                Index = index,

                                CurrencyVal = self.Currency[currency]
                            })
                        end)
                    }
                }),

                FakeTopBGTex(scope)
            }
        },

        CenterProps = {
            ZIndex = 10,

            [Children] = {
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
        }
    })
    self.UI = UI


    return function ()
        Fusion.doCleanup(scope)
    end
end