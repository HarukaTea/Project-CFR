
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)


local ProductBar = require(script.Components.ProductBar)
local PurchasePrompt = require(script.Components.PurchasePrompt)
local TopbarCategoryBtn = require(RepS.HarukaShared.UIAtlas.Components.TopbarCategoryBtn)
local BottombarEcoSlot = require(RepS.HarukaShared.UIAtlas.Components.BottombarEcoSlot)

local BKItemDescView = require(RepS.HarukaShared.UIAtlas.Components.BKItemDescView)
local BKItemFilterView = require(RepS.HarukaShared.UIAtlas.Components.BKItemFilterView)
local BKItemListView = require(RepS.HarukaShared.UIAtlas.Components.BKItemListView)
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
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(self.CurrentCategory) == "Market"
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
                                return ProductBar(scope, {
                                    ProductId = itemInfo.ProductId,
                                    UniqueId = itemInfo.ProductUniqueId,

                                    CurrentSelectedItem = self.CurrentSelectedItem,
                                    CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,
                                })
                            end)
                        }
                    }, {
                        Padding = UDim.new(0, 10),
                    }),
                }
            }),


            Components.Frame(scope, {
                Name = "CenterLeft_Selling",
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0.03, 0.52),
                Size = UDim2.fromScale(0.65, 0.66),
                ClipsDescendants = true,

                Interactable = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(self.IsPurchasing)
                end),
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(self.CurrentCategory) == "Sell"
                end),

                [Children] = {
                    BKItemListView(scope, self),

                    Components.TextLabel(scope, {
                        Name = "Empty",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 0.1),
                        Text = "EMPTY",
                        TextTransparency = 0.8,

                        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(self.AvailableItems).X <= 0
                        end)
                    })
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
                        if use(self.CurrentCategory) == "Sell" then
                            return BKItemDescView(scope, {
                                Item = use(self.CurrentSelectedItem),
                                ItemUniqueId = use(self.CurrentSelectedItemUniqueId),
                                EquippingItems = self.EquippingItems,
                                Items = use(self.Items),
                            })
                        elseif use(self.CurrentCategory) == "Market" then
                            return BKItemDescView(scope, {
                                Item = use(self.CurrentSelectedItem),
                                ItemUniqueId = use(self.CurrentSelectedItemUniqueId),
                                EquippingItems = self.EquippingItems,
                                IsMarket = true
                            })
                        else
                            return nil
                        end
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
            }),


            Components.Frame(scope, {
                Name = "Left",
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(0.3, 1),
                ZIndex = 3,

                [Children] = {
                    Components.Frame(scope, {
                        Name = "FilterOptions",
                        ZIndex = 10,

                        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(self.FilterViewShown)
                        end),

                        [Children] = {
                            Components.Frame(scope, {
                                Name = "Shadows",
                                AnchorPoint = Vector2.new(0, 0),
                                Position = UDim2.fromScale(1, 0),
                                BackgroundColor3 = Color3.fromRGB(),
                                BackgroundTransparency = 0,

                                [Children] = {
                                    Components.UIGradient(scope, {
                                        Transparency = NumberSequence.new(1, 0.5),
                                        Rotation = 180
                                    })
                                }
                            }),

                            Components.Frame(scope, {
                                Name = "Inner",
                                ZIndex = 2,

                                [Children] = {
                                    BKItemFilterView(scope, {
                                        FilterTierList = self.FilterTierList,
                                        FilterItemText = self.FilterItemText,
                                        SortMethodList = self.SortMethodList
                                    })
                                }
                            })
                        }
                    })
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


                        Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local curCategory = use(self.CurrentCategory) :: string
                            local curItem = use(self.CurrentSelectedItem) :: string

                            if curCategory == "Market" and curItem ~= "" then
                                return ExecuteButton(scope, {
                                    Size = UDim2.fromScale(0.15, 0.7),
                                    ButtonText = "Purchase",
                                    ButtonType = "Confirm",
                                    ButtonClickFunc = function()
                                        self.IsPurchasing:set(true)
                                        self.CurrentPurchaseAction:set("Purchase")
                                    end
                                })
                            elseif curCategory == "Sell" and curItem ~= "" then
                                return {
                                    ExecuteButton(scope, {
                                        Size = UDim2.fromScale(0.15, 0.7),
                                        ButtonText = "Sell",
                                        ButtonType = "Cancel",
                                        ButtonClickFunc = function()
                                            self.IsPurchasing:set(true)
                                            self.CurrentPurchaseAction:set("Sell")
                                        end
                                    }),
                                    ExecuteButton(scope, {
                                        Size = UDim2.fromScale(0.15, 0.7),
                                        ButtonText = "Sell All",
                                        ButtonType = "Cancel",
                                        ButtonClickFunc = function()
                                            local result = Components:CreateConfirmPrompt(scope, {
                                                Hint = "Are you sure you want to sell <red>all items with this name</font>? We'll keep one as a backup for you.",
                                                CancelText = "NO",
                                                ConfirmText = "YES",

                                                ConfirmUniqueId = "ConfirmSellAllItemsInMarket"
                                            }):Wait()

                                            if result and result == "YES" then
                                                Events.SellAllItems_C.Fire({
                                                    ItemId = Fusion.peek(self.CurrentSelectedItem)
                                                })
                                            end
                                        end
                                    })
                                }
                            else
                                return nil
                            end
                        end),
                    }
                }),

                Components.Frame(scope, {
                    Name = "LSideBtns",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, -0.3),
                    Size = UDim2.fromScale(0.96, 1),

                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return use(self.CurrentCategory) == "Sell"
                    end),
                    Interactable = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return not use(self.IsPurchasing)
                    end),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Left,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            Padding = UDim.new(0.015, 0),
                        }),

                        BottombarOptionBtn(scope, {
                            Option = "Filter",
                            Index = 1
                        }, self),

                        Fusion.ForPairs(scope, { "Accessory", "Weapon", "Active", "Material" }, function(_, scope: Fusion.Scope, index: number, category: string)
                            return index, TopbarCategoryBtn(scope, {
                                Category = category,
                                Index = index + 2,

                                CurrentSelectedItem = self.CurrentSelectedItem,
                                CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,
                                CurrentCategory = self.CurrentItemCategory,
                            })
                        end),
                    }
                }),


                Components.Frame(scope, {
                    Name = "FilterModeStatus",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, -0.1),

                    [Children] = {
                        Components.TextLabel(scope, {
                            Name = "FilterModeHint",
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.fromScale(0.52, 0.5),
                            AutomaticSize = Enum.AutomaticSize.X,
                            Text = "FILTER MODE: ON",
                            BackgroundTransparency = 0,
                            BackgroundColor3 = Components.WHITE_COLOR,
                            TextColor3 = Components.BLACK_COLOR,
                            Size = UDim2.fromScale(0, 0.56),


                            Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                local check = false
                                for _, tierStatus in self.FilterTierList do
                                    if use(tierStatus) == false then
                                        check = true
                                        break
                                    end
                                end
                                if use(self.FilterItemText) ~= "" then check = true end

                                return check
                            end),


                            [Children] = {
                                Components.RoundUICorner(scope),
                                Components.UIPadding(scope, {
                                    PaddingLeft = UDim.new(0, 9),
                                    PaddingRight = UDim.new(0, 9)
                                })
                            }
                        })
                    }
                })
            }
        },

        TopProps = {
            Position = UDim2.fromScale(0.5, 0.02),

            [Children] = {
                Components.Frame(scope, {
                    Name = "Categories",

                    Interactable = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return not use(self.IsPurchasing)
                    end),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            Padding = UDim.new(0.015, 0),
                        }),

                        Fusion.ForPairs(scope, { "Market", "Sell" }, function(_, scope: Fusion.Scope, index: number, category: string)
                            return index, TopbarCategoryBtn(scope, {
                                Category = category,
                                Index = index,

                                CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,
                                CurrentSelectedItem = self.CurrentSelectedItem,
                                CurrentCategory = self.CurrentCategory,
                            })
                        end)
                    }
                }),

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

                        Fusion.ForPairs(scope, { "Gold" }, function(_, scope: Fusion.Scope, index: number, currency: string)
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
                Fusion.Computed(scope, function(use: Fusion.Use, _)
                    if not use(self.IsPurchasing) then return nil end

                    return PurchasePrompt(scope, {
                        ProductId = use(self.CurrentSelectedItem),
                        UniqueId = use(self.CurrentSelectedItemUniqueId),

                        IsPurchasing = self.IsPurchasing,
                        Action = use(self.CurrentPurchaseAction),

                        CurrentSelectedItem = self.CurrentSelectedItem,
                        CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,
                    })
                end)
            }
        }
    })

    return function ()
        Fusion.doCleanup(scope)


    end
end