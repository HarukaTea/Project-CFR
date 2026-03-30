
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
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

    ClientLib:InitUIFramework(self, plr, "ExplorerCrafting")

    Pinia(self)

    local scope = self.scope :: Fusion.Scope

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerCrafting",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("CenterLeft_ECraft1_1"))({
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

                    Fusion.Hydrate(scope, Components:RefUI("Empty_BK1_1"))({
                        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(self.AvailableItems).X <= 0
                        end)
                    })
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("Center2_BK1_1", false, true))({
                [Children] = {
                    Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                        return BKItemDescView(scope, {
                            Item = use(self.CurrentSelectedItem),
                            ItemUniqueId = use(self.CurrentSelectedItemUniqueId),
                            EquippingItems = self.EquippingItems,
                            Items = use(self.Items),
                        })
                    end),

                    Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                        return BKItemQuickDescView(scope, {
                            Item = use(self.CurrentSelectedMaterial),

                            ItemVal = self.CurrentSelectedMaterial,
                            IsViewingVal = self.IsCrafting
                        })
                    end),
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("Top2_BK1_1", false, true))({
                [Children] = {
                    CloseTab(scope, {
                        ViewShownValue = self.IsUIShown
                    }),
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("Left_BK1_1"))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("FilterOptions_BK1_1", false, false, {
                        "Shadows"
                    }))({
                        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(self.FilterViewShown)
                        end),

                        [Children] = {
                            Fusion.Hydrate(scope, Components:RefUI("Inner_FOBK1_1"))({
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

            Fusion.Hydrate(scope, Components:RefUI("ShadowOverlay2_BK1_1"))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(self.IsCrafting)
                end)
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
            Fusion.Hydrate(scope, Components:RefUI("Categories_BK1_1", false, true))({
                [Children] = {
                    Fusion.ForPairs(scope, {
                        "Accessory", "Artifact", "Weapon", "Active", "Material", "Misc"
                    }, function(_, scope: Fusion.Scope, index: number, category: string)
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

            FakeTopBGTex(scope)
        },

        CenterProps = {
            ZIndex = 2
        },
        CenterChildren = {
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
            end),
        },

        BottomChildren = {
            Fusion.Hydrate(scope, Components:RefUI("LSideBtns_BK1_1", false, true))({
                [Children] = {
                    BottombarOptionBtn(scope, {
                        Option = "Filter",
                        Index = 1
                    }, self),
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("RSideBtns_BK1_1", false, true))({
                [Children] = {
                    Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                        local item = use(self.CurrentSelectedItem) :: string
                        local itemInfo = ItemBook:GetItemInfo(item)
                        if itemInfo == nil then return nil end

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

            Fusion.Hydrate(scope, Components:RefUI("FilterModeStatus_BK1_1"))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("FilterModeHint_BK1_1", true))({
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
                        end)
                    })
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("CraftingMaterials_ECraft1_1", false, false, {
                "Title"
            }))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local currentItem = use(self.CurrentSelectedItem) :: string
                    currentItem = currentItem or ""
                    return currentItem ~= ""
                end),

                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("Materials_ECraft2_1", false, true))({
                        [Children] = {
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
                                if price <= 0 then return nil end

                                return CraftGoldMatSlot(scope, {
                                    GoldVal = self.Gold,
                                    Amount = price
                                })
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