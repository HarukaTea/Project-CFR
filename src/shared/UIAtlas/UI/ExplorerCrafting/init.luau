
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

local BKItemDescView = require(RepS.HarukaShared.UIAtlas.Components.BKItemDescView)
local BKItemQuickDescView = require(RepS.HarukaShared.UIAtlas.Components.BKItemQuickDescView)
local BKItemFilterView = require(RepS.HarukaShared.UIAtlas.Components.BKItemFilterView)
local BKItemQuickSlot = require(RepS.HarukaShared.UIAtlas.Components.BKItemQuickSlot)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)
local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)
local FakeTopBGTex = require(RepS.HarukaShared.UIAtlas.Components.FakeTopBGTex)

local TopbarCategoryBtn = require(RepS.HarukaShared.UIAtlas.Components.TopbarCategoryBtn)
local BottombarOptionBtn = require(RepS.HarukaShared.UIAtlas.Components.BottombarOptionBtn)

local CraftItemMatSlot = require(script.Components.CraftItemMatSlot)
local CraftGoldMatSlot = require(script.Components.CraftGoldMatSlot)

local MKPurchasePrompt = require(RepS.HarukaShared.UIAtlas.Components.MKPurchasePrompt)

local Children = Fusion.Children

local Pinia = require(script.Pinia)

return function (plr: Player)
    local self = {} :: Pinia.Self

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope

    Pinia(self)

    if plr.PlayerGui:FindFirstChild("ExplorerCrafting") then
        plr.PlayerGui.ExplorerCrafting:Destroy()
    end

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerCrafting",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end),

        [Children] = {
            Components.Frame(scope, {
                Name = "CenterLeft",
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0.03, 0.421),
                Size = UDim2.fromScale(0.6, 0.462),
                ClipsDescendants = true,

                [Children] = {
                    Components.ScrollingFrame(scope, {
                        Name = "Items",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.97, 0.95),
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                        ClipsDescendants = false,

                        Interactable = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return not use(self.IsCrafting)
                        end),

                        [Fusion.Out("AbsoluteSize")] = self.ItemListAbsSize,

                        [Children] = {
                            Fusion.ForPairs(scope, self.Items, function(use: Fusion.Use, scope: Fusion.Scope<any>, index: number, itemSymbol: IntConstrainedValue)
                                if not use(self.IsUIShown) then return nil end

                                local info = ItemBook:GetItemInfo(itemSymbol.Name)
                                if not info then return nil end

                                local isVisible = false
                                local isVisibleFactor2 = false
                                local category = use(self.CurrentCategory) :: string

                                if category == "Misc" then
                                    category = { "Quest", "Cosmetic", "Title" }
                                elseif category == "Active" then
                                    category = { "Consumable", "Active" }
                                elseif category == "Accessory" then
                                    category = { "Accessory", "Passive" }
                                else
                                    category = { category }
                                end
                                isVisible = table.find(category, info.Type) ~= nil

                                local tierNum = info.Tier - ((info.Tier - 1) % 2)
                                tierNum = math.clamp(tierNum, 1, 3)

                                local state = use(self.FilterTierList[tierNum])
                                isVisibleFactor2 = state

                                local isVisibleFactor3 = false
                                local text = use(self.FilterItemText)
                                local textWithoutSpaces = string.gsub(text, " ", "")

                                if textWithoutSpaces == "" then
                                    isVisibleFactor3 = true
                                else
                                    textWithoutSpaces = textWithoutSpaces :: string

                                    if string.find(string.lower(info.Name), string.lower(textWithoutSpaces)) then
                                        isVisibleFactor3 = true
                                    else
                                        isVisibleFactor3 = false
                                    end
                                end

                                if isVisible and isVisibleFactor2 and isVisibleFactor3 then
                                    return index, BKItemQuickSlot(scope, {
                                        ItemSymbol = itemSymbol,

                                        CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,
                                        CurrentSelectedItem = self.CurrentSelectedItem,
                                        CurrentSortOrderList = self.SortMethodList,
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
                                        SortMethodList = self.SortMethodList,

                                        UIOpenState = self.FilterViewShown
                                    })
                                }
                            })
                        }
                    })
                }
            }),

            Components.Frame(scope, {
                Name = "Center_ZIndex2",
                Size = UDim2.fromScale(1, 0.1),
                ZIndex = 10,

                [Children] = {
                    Components.UIAspectRatioConstraint(scope),

                    Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                        if not use(self.IsCrafting) then return nil end

                        return MKPurchasePrompt(scope, {
                            ProductId = use(self.CurrentSelectedItem),
                            UniqueId = use(self.CurrentSelectedItemUniqueId),

                            IsPurchasing = self.IsCrafting,
                            Action = "Craft",

                            CurrentSelectedItem = self.CurrentSelectedItem,
                            CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,

                            CurrencyId = "Gold",
                        })
                    end)
                }
            }),

            Components.Frame(scope, {
                Name = "ShadowOverlay2",
                BackgroundTransparency = 0.3,
                ZIndex = 3,
                Interactable = false,
                Active = false,

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(self.IsCrafting)
                end),
            }),
        }

    }, {
        FullProps = {
            BackgroundTransparency = 0.3,
            ZIndex = 0,
        },

        TopProps = {
            Position = UDim2.fromScale(0.5, 0.02)
        },
        TopChildren = {
            Components.Frame(scope, {
                Name = "Categories",

                [Children] = {
                    Components.UIListLayout(scope, {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0.015, 0),
                    }),

                    Fusion.ForPairs(scope, { "Accessory", "Artifact", "Weapon", "Active", "Material", "Misc" }, function(_, scope: Fusion.Scope, index: number, category: string)
                        return index, TopbarCategoryBtn(scope, {
                            Category = category,
                            Index = index,

                            CurrentSelectedItem = self.CurrentSelectedItem,
                            CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,
                            CurrentCategory = self.CurrentCategory,
                        })
                    end)
                }
            }),

            CloseTab(scope, {
                ViewShownValue = self.IsUIShown
            }),
            FakeTopBGTex(scope)
        },

        CenterProps = {
            ZIndex = 2
        },
        CenterChildren = {
            Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                return BKItemDescView(scope, {
                    Item = use(self.CurrentSelectedItem),
                    ItemUniqueId = use(self.CurrentSelectedItemUniqueId),
                    EquippingItems = self.EquippingItems,

                    IsCrafting = true
                })
            end),

            Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                return BKItemQuickDescView(scope, {
                    Item = use(self.CurrentSelectedMaterial),

                    ItemVal = self.CurrentSelectedMaterial,
                    IsViewingVal = self.IsCrafting
                })
            end),
        },

        BottomChildren = {
            Components.Frame(scope, {
                Name = "LSideBtns",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, -0.3),
                Size = UDim2.fromScale(0.96, 1),

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
                }
            }),

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

                    Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                        local item = use(self.CurrentSelectedItem) :: string
                        local itemInfo = ItemBook:GetItemInfo(item)
                        if itemInfo == nil then
                            return nil
                        end

                        return ExecuteButton(scope, {
                            Size = UDim2.fromScale(0.15, 0.7),
                            ButtonText = "Craft",
                            ButtonType = "Confirm",
                            ButtonClickFunc = function()
                                self.IsCrafting:set(true)
                            end
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
                        Position = UDim2.fromScale(0.4, 0.5),
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
                                PaddingLeft = UDim.new(0, 15),
                                PaddingRight = UDim.new(0, 15)
                            })
                        }
                    })
                }
            }),

            Components.Frame(scope, {
                Name = "CraftingMaterials",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, -1.5),

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local currentItem = use(self.CurrentSelectedItem) :: string
                    currentItem = currentItem or ""

                    return currentItem ~= ""
                end),

                [Children] = {
                    Components.Frame(scope, {
                        Name = "Title",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0.2, -1),
                        Size = UDim2.fromScale(0.48, 1),
                        ClipsDescendants = true,

                        [Children] = {
                            Components.UIListLayout(scope, {
                                FillDirection = Enum.FillDirection.Horizontal,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                            }),

                            Components.TextLabel(scope, {
                                Name = "Title",
                                AutomaticSize = Enum.AutomaticSize.X,
                                Size = UDim2.fromScale(0, 0.6),
                                Text = "MATERIALS",
                                TextTransparency = 0.5,

                                [Children] = {
                                    Components.UIPadding(scope, {
                                        PaddingTop = UDim.new(0.05, 0),
                                        PaddingBottom = UDim.new(0.05, 0),
                                        PaddingLeft = UDim.new(0.05, 0),
                                        PaddingRight = UDim.new(0, 12)
                                    })
                                }
                            }),
                            Components.Frame(scope, {
                                Name = "Bar",
                                Size = UDim2.fromScale(0.5, 0.07),
                                BackgroundTransparency = 0.8,
                                BackgroundColor3 = Components.WHITE_COLOR,
                                LayoutOrder = 2,
                            })
                        }
                    }),
                    Components.Frame(scope, {
                        Name = "Materials",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0.2, 0),
                        ZIndex = 2,

                        [Children] = {
                            Components.UIListLayout(scope, {
                                Padding = UDim.new(0.01, 0),
                                FillDirection = Enum.FillDirection.Horizontal,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                            }),

                            Fusion.ForPairs(scope, self.CraftingMaterials, function(_, scope: Fusion.Scope, itemId: string, amount: number)
                                return itemId, CraftItemMatSlot(scope, {
                                    ItemId = itemId,
                                    Items = self.PlayerItems,
                                    Amount = amount,

                                    SelectedMaterialVal = self.CurrentSelectedMaterial,
                                })
                            end),

                            Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                                local price = use(self.CraftingPrice) :: number

                                if price > 0 then
                                    return CraftGoldMatSlot(scope, {
                                        GoldVal = self.Gold,
                                        Amount = price
                                    })
                                else
                                    return nil
                                end
                            end),

                        }
                    })
                }
            })
        }
    })
    self.UI = UI

    return function ()
        Fusion.doCleanup(scope)
    end
end