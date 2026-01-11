
local RepS = game:GetService("ReplicatedStorage")

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

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope

    Pinia(self)

    if plr.PlayerGui:FindFirstChild("ExplorerBackpack") then
        plr.PlayerGui.ExplorerBackpack:Destroy()
    end

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerBackpack",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end),

        [Children] = {
            Components.Frame(scope, {
                Name = "CenterLeft",
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0.03, 0.52),
                Size = UDim2.fromScale(0.65, 0.66),
                ClipsDescendants = true,

                [Children] = {
                    BKItemListView(scope, self, true),

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

                [Children] = {
                    CloseTab(scope, {
                        ViewShownValue = self.IsUIShown
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
                            Items = use(self.Items),
                        })
                    end),
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
                    Name = "Economy",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, -0.3),
                    Size = UDim2.fromScale(0.85, 1),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Left,
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
                            local itemUniqueId = use(self.CurrentSelectedItemUniqueId) :: string

                            local itemInfo = ItemBook:GetItemInfo(item)
                            if itemInfo == nil then
                                return nil
                            end

                            local blackList = { "Material", "Quest", "Passive" }
                            if table.find(blackList, itemInfo.Type) then
                                return nil
                            end

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
                                if not found then
                                    return ExecuteButton(scope, {
                                        Size = UDim2.fromScale(0.15, 0.7),
                                        ButtonText = "Equip",
                                        ButtonType = "Confirm",
                                        LayoutOrder = 233,
                                        ButtonClickFunc = function()
                                            _requestToEquip()
                                        end
                                    })
                                else
                                    return nil
                                end
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
                            if itemInfo == nil then
                                return nil
                            end

                            local blackList = { "Quest", "Passive", "Cosmetic", "Title" }
                            if table.find(blackList, itemInfo.Type) then
                                return nil
                            end

                            return {
                                ExecuteButton(scope, {
                                    Size = UDim2.fromScale(0.115, 0.7),
                                    ButtonText = "Sell",
                                    ButtonType = "Cancel",
                                    LayoutOrder = 2,
                                    ButtonClickFunc = function()
                                        self.IsPurchasing:set(true)
                                    end
                                })
                            }
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

                FakeTopBGTex(scope)
            }
        },

        CenterProps = {
            ZIndex = 10,

            [Children] = {
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
        }
    })
    self.UI = UI

    return function ()
        Fusion.doCleanup(scope)

    end
end