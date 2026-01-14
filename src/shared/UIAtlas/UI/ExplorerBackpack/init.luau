
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local BottombarOptionBtn = require(RepS.HarukaShared.UIAtlas.Components.BottombarOptionBtn)
local TopbarCategoryBtn = require(RepS.HarukaShared.UIAtlas.Components.TopbarCategoryBtn)
local BottombarEcoSlot = require(RepS.HarukaShared.UIAtlas.Components.BottombarEcoSlot)

local BKItemDescView = require(RepS.HarukaShared.UIAtlas.Components.BKItemDescView)
local BKItemFilterView = require(RepS.HarukaShared.UIAtlas.Components.BKItemFilterView)
local BKItemListView = require(script.Components.BKItemListView)

local MKPurchasePrompt = require(RepS.HarukaShared.UIAtlas.Components.MKPurchasePrompt)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)
local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)
local FakeTopBGTex = require(RepS.HarukaShared.UIAtlas.Components.FakeTopBGTex)

local Children = Fusion.Children

local Pinia = require(script.Pinia)

return function (plr: Player)
    local self = {} :: Pinia.Self

    ClientLib:InitUIFramework(self, plr, "ExplorerBackpack")

    Pinia(self)

    local scope = self.scope :: Fusion.Scope

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerBackpack",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("CenterLeft_BK1_1"))({
                [Children] = {
                    BKItemListView(scope, self, true),

                    Fusion.Hydrate(scope, Components:RefUI("Empty_BK1_1"))({
                        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(self.AvailableItems).X <= 0
                        end)
                    })
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

            Fusion.Hydrate(scope, Components:RefUI("Center2_BK1_1", false, true))({
                Interactable = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(self.IsPurchasing)
                end),

                [Children] = {
                    Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                        return BKItemDescView(scope, {
                            Item = use(self.CurrentSelectedItem),
                            ItemUniqueId = use(self.CurrentSelectedItemUniqueId),
                            EquippingItems = self.EquippingItems,
                            Items = use(self.Items),
                        })
                    end),
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
            })
        }

    }, {
        FullProps = {
            BackgroundTransparency = 0.3,
            ZIndex = 0
        },

        BottomChildren = {
            Fusion.Hydrate(scope, Components:RefUI("Economy_BK1_1", false, true))({
                [Children] = {
                    Fusion.ForPairs(scope, { "Gold" }, function(_, scope: Fusion.Scope, index: number, currency: string)
                        return index, BottombarEcoSlot(scope, {
                            Currency = currency,
                            Index = index,

                            CurrencyVal = self.Currency[currency]
                        })
                    end)
                }
            }),

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
                        local itemUniqueId = use(self.CurrentSelectedItemUniqueId) :: string

                        local itemInfo = ItemBook:GetItemInfo(item)
                        if itemInfo == nil then return nil end

                        local blackList = { "Material", "Quest", "Passive" }
                        if table.find(blackList, itemInfo.Type) then return nil end

                        local equippingItems = use(self.EquippingItems)
                        local found = false
                        for _, equipping: StringValue in equippingItems do
                            if (equipping:GetAttribute("HarukaUniqueId") or "nil") == itemUniqueId then
                                found = true
                                break
                            end
                        end

                        local function _requestToEquip()
                            if self.EquipCD then return end

                            self.EquipCD = true
                            task.delay(0.3, function()
                                if self == nil then return end
                                self.EquipCD = false
                            end)

                            local curItem = Fusion.peek(self.CurrentSelectedItem) :: string
                            local curItemUniqueId = Fusion.peek(self.CurrentSelectedItemUniqueId) :: string

                            if curItem and curItem ~= "" and curItemUniqueId and curItemUniqueId ~= "" then
                                Events.EquipItem_C.Fire({
                                    ItemId = Fusion.peek(self.CurrentSelectedItem),
                                    ItemUniqueId = Fusion.peek(self.CurrentSelectedItemUniqueId),
                                })
                            end
                        end

                        if itemInfo.Type == "Weapon" then
                            if found then return nil end

                            return ExecuteButton(scope, {
                                Size = UDim2.fromScale(0.15, 0.7),
                                ButtonText = "Equip",
                                ButtonType = "Confirm",
                                LayoutOrder = 233,
                                ButtonClickFunc = function()
                                    _requestToEquip()
                                end
                            })
                        end
                        if found then
                            return ExecuteButton(scope, {
                                Size = UDim2.fromScale(0.15, 0.7),
                                ButtonText = "Unequip",
                                ButtonType = "Cancel",
                                LayoutOrder = 233,
                                ButtonClickFunc = function()
                                    _requestToEquip()
                                end
                            })
                        else
                            return ExecuteButton(scope, {
                                Size = UDim2.fromScale(0.15, 0.7),
                                ButtonText = "Equip",
                                ButtonType = "Confirm",
                                LayoutOrder = 233,
                                ButtonClickFunc = function()
                                    _requestToEquip()
                                end
                            })
                        end
                    end),

                    Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                        local item = use(self.CurrentSelectedItem) :: string

                        local itemInfo = ItemBook:GetItemInfo(item)
                        if itemInfo == nil then return nil end

                        local blackList = { "Quest", "Passive", "Cosmetic", "Title" }
                        if table.find(blackList, itemInfo.Type) then return nil end

                        return ExecuteButton(scope, {
                            Size = UDim2.fromScale(0.115, 0.7),
                            ButtonText = "Sell",
                            ButtonType = "Cancel",
                            LayoutOrder = 2,
                            ButtonClickFunc = function()
                                self.IsPurchasing:set(true)
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
            })
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
            ZIndex = 10
        },
        CenterChildren = {
            Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                if not use(self.IsPurchasing) then return nil end

                return MKPurchasePrompt(scope, {
                    ProductId = use(self.CurrentSelectedItem),
                    UniqueId = use(self.CurrentSelectedItemUniqueId),

                    IsPurchasing = self.IsPurchasing,
                    Action = "Sell",

                    CurrentSelectedItem = self.CurrentSelectedItem,
                    CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,

                    CurrencyId = "Gold",
                })
            end)
        }
    })
    self.UI = UI

    return function ()
        Fusion.doCleanup(scope)
    end
end