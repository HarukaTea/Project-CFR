--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)
local ItemLib = require(RepS.HarukaShared.Library.ItemLib)


local ProductBar = require(script.Components.ProductBar)
local PurchasePrompt = require(script.Components.PurchasePrompt)
local BKCategoryBtn = require(RepS.HarukaShared.UIAtlas.UI.ExplorerBackpack.Components.BKCategoryBtn)
local BKEcoSlot = require(RepS.HarukaShared.UIAtlas.UI.ExplorerBackpack.Components.BKEcoSlot)
local BKItemFilterView = require(RepS.HarukaShared.UIAtlas.UI.ExplorerBackpack.Components.BKItemFilterView)
local BKItemDescView = require(RepS.HarukaShared.UIAtlas.UI.ExplorerBackpack.Components.BKItemDescView)
local BKItemSlot = require(RepS.HarukaShared.UIAtlas.UI.ExplorerBackpack.Components.BKItemSlot)
local BKOptionBtn = require(RepS.HarukaShared.UIAtlas.UI.ExplorerBackpack.Components.BKOptionBtn)


local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)
local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)

local Children = Fusion.Children

return function (plr: Player)
    local self = {}

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope


    require(script.Pinia)(self)


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
                            Fusion.ForValues(scope, self.Products, function(_, scope: Fusion.Scope, itemInfo: string)
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
                        SortOrder = Enum.SortOrder.Name,
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
                    Components.ScrollingFrame(scope, {
                        Name = "Backpack",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.97, 0.95),
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                        ClipsDescendants = false,

                        [Fusion.Out("AbsoluteSize")] = self.ItemListAbsSize,

                        [Children] = {
                            Fusion.ForPairs(scope, self.Items, function(use: Fusion.Use, scope: Fusion.Scope, index: number, itemSymbol: IntConstrainedValue)
                                if not use(self.IsUIShown) then return nil end
                                if use(self.CurrentCategory) ~= "Sell" then return nil end

                                local info = ItemLib:GetItemInfo(itemSymbol.Name)
                                if not info then return nil end

                                local isVisible = false
                                local isVisibleFactor2 = false
                                local category = use(self.CurrentItemCategory) :: string

                                if category == "Misc" then
                                    category = { "Recipe", "Quest", "Cosmetic" }
                                elseif category == "Active" then
                                    category = { "Consumable", "Active" }
                                elseif category == "Accessory" then
                                    category = { "Accessory", "Passive" }
                                else
                                    category = { category }
                                end
                                isVisible = table.find(category, info.Type) ~= nil


                                local state = use(self.FilterTierList[info.Tier])
                                isVisibleFactor2 = state


                                local isVisibleFactor3 = false
                                local text = use(self.FilterItemText)
                                local textWithoutSpaces = string.gsub(text, " ", "")

                                if textWithoutSpaces == "" then
                                    isVisibleFactor3 = true
                                else
                                    if string.find(string.lower(info.Name), string.lower(textWithoutSpaces)) then
                                        isVisibleFactor3 = true
                                    else
                                        isVisibleFactor3 = false
                                    end
                                end

                                if isVisible and isVisibleFactor2 and isVisibleFactor3 then
                                    return index, BKItemSlot(scope, {
                                        ItemSymbol = itemSymbol,
                                        EquippingItems = self.EquippingItems,

                                        CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,
                                        CurrentSelectedItem = self.CurrentSelectedItem,
                                    })
                                else
                                    return index, nil
                                end
                            end)
                        }
                    }, {
                        CellSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local size = use(self.ItemListAbsSize) :: Vector2
                            local x = size.X * 0.125 * 0.86
                            local y = size.X * 0.135 * 0.86

                            return UDim2.fromOffset(x, y)
                        end),
                        CellPadding = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local size = use(self.ItemListAbsSize) :: Vector2
                            local x = size.X * 0.015
                            local y = size.X * 0.023

                            return UDim2.fromOffset(x, y)
                        end),

                        [Fusion.Out("AbsoluteCellCount")] = self.AvailableItems,

                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.Name
                    }),

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

                [Children] = {
                    Components.UIAspectRatioConstraint(scope),

                    Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                        if use(self.CurrentCategory) == "Sell" then
                            return BKItemDescView(scope, {
                                Item = use(self.CurrentSelectedItem),
                                ItemUniqueId = use(self.CurrentSelectedItemUniqueId),
                                Items = use(self.Items),
                            })
                        elseif use(self.CurrentCategory) == "Market" then
                            return BKItemDescView(scope, {
                                Item = use(self.CurrentSelectedItem),
                                ItemUniqueId = use(self.CurrentSelectedItemUniqueId),
                                IsMarket = true
                            })
                        else
                            return nil
                        end
                    end),

                    Components.Frame(scope, {
                        Name = "FilterOptions",
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 0,
                        Size = UDim2.fromScale(0.28, 7),

                        Position = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local itemInfo = ItemLib:GetItemInfo(use(self.CurrentSelectedItem))
                            if itemInfo == nil then
                                return UDim2.fromScale(0.98, 0.8)
                            end

                            return UDim2.fromScale(0.67, 0.8)
                        end),

                        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(self.FilterViewShown)
                        end),

                        [Children] = {
                            Components.UICorner(scope, { CornerRadius = UDim.new(0.015, 0) }),

                            Components.UIStroke(scope, {
                                Thickness = 6,
                                Color = Color3.new()
                            }),

                            BKItemFilterView(scope, {
                                FilterTierList = self.FilterTierList,
                                FilterItemText = self.FilterItemText
                            })
                        }
                    })
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
                                                Events.RequestToSellAllItems.Fire({
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

                    [Children] = {
                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Left,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            Padding = UDim.new(0.015, 0),
                        }),

                        BKOptionBtn(scope, {
                            Option = "Filter",
                            Index = 1
                        }, self),

                        Fusion.ForPairs(scope, { "Accessory", "Weapon", "Active", "Material" }, function(_, scope: Fusion.Scope, index: number, category: string)
                            return index, BKCategoryBtn(scope, {
                                Category = category,
                                Index = index + 2,

                                CurrentSelectedItem = self.CurrentSelectedItem,
                                CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,
                                CurrentCategory = self.CurrentItemCategory,
                                CurrentItemLimit = self.ItemShownSlotsLimit
                            })
                        end),

                        Components.TextButton(scope, {
                            Name = "LoadMore",
                            AnchorPoint = Vector2.new(1, 0.5),
                            BackgroundColor3 = Color3.fromRGB(123, 237, 159),
                            BackgroundTransparency = 0,
                            LayoutOrder = 999,
                            Size = UDim2.fromScale(0.11, 0.55),
                            Text = "SHOW MORE",
                            TextColor3 = Color3.fromRGB(),

                            [Fusion.OnEvent("MouseButton1Click")] = function()
                                local limit = Fusion.peek(self.ItemShownSlotsLimit) :: number

                                limit += 100
                                self.ItemShownSlotsLimit:set(limit)
                            end,

                            [Children] = {
                                Components.RoundUICorner(scope),
                                Components.UIPadding(scope, {})
                            }
                        })
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
                                for _, tierStatus: Fusion.Value in self.FilterTierList do
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

                    [Children] = {
                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            Padding = UDim.new(0.015, 0),
                        }),

                        Fusion.ForPairs(scope, { "Market", "Sell" }, function(_, scope: Fusion.Scope, index: number, category: string)
                            return index, BKCategoryBtn(scope, {
                                Category = category,
                                Index = index,

                                CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,
                                CurrentSelectedItem = self.CurrentSelectedItem,
                                CurrentCategory = self.CurrentCategory,
                                CurrentItemLimit = self.ItemShownSlotsLimit
                            })
                        end)
                    }
                }),

                Components.Frame(scope, {
                    Name = "Economy",
                    Size = UDim2.fromScale(0.82, 1),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Right,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            Padding = UDim.new(0.015, 0),
                        }),

                        Fusion.ForPairs(scope, { "Gold", "Astra" }, function(_, scope: Fusion.Scope, index: number, currency: string)
                            return index, BKEcoSlot(scope, {
                                Currency = currency,
                                Index = index,

                                CurrencyVal = self.Currency[currency]
                            })
                        end)
                    }
                }),

                CloseTab(scope, {
                    ViewShownValue = self.IsUIShown
                }),

                Components.Frame(scope, {
                    Name = "FakeTopBG",
                    BackgroundTransparency = 0.1,
                    Size = UDim2.fromScale(2, 1.8),
                    ZIndex = 0,
                })
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


    require(script.Anims)(UI, self)


    return function ()
        Fusion.doCleanup(scope)


    end
end