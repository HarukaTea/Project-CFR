--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local BKOptionBtn = require(script.Components.BKOptionBtn)
local BKCategoryBtn = require(script.Components.BKCategoryBtn)
local BKEcoSlot = require(script.Components.BKEcoSlot)
local BKItemSlot = require(script.Components.BKItemSlot)

local BKItemDescView = require(script.Components.BKItemDescView)
local BKItemFilterView = require(script.Components.BKItemFilterView)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)
local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)
local FakeTopBG = require(RepS.HarukaShared.UIAtlas.Components.FakeTopBGTex)

local Children = Fusion.Children

return function (plr: Player)
    local self = {}

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope


    require(script.Pinia)(self)


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
                                local info = ItemBook:GetItemInfo(itemSymbol.Name)
                                if not info then return nil end

                                local isVisible = false
                                local isVisibleFactor2 = false
                                local category = use(self.CurrentCategory) :: string

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

                                        IsBackpack = true,

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
                Name = "Right",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.fromScale(1, 0),
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
                                Position = UDim2.fromScale(-1, 0),
                                BackgroundColor3 = Color3.fromRGB(),
                                BackgroundTransparency = 0,

                                [Children] = {
                                    Components.UIGradient(scope, {
                                        Transparency = NumberSequence.new(1, 0.5)
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
                            return index, BKEcoSlot(scope, {
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

                        BKOptionBtn(scope, {
                            Option = "Filter",
                            Index = 1
                        }, self),

                        Components.Frame(scope, {
                            Name = "Padding",
                            LayoutOrder = 2,
                            Size = UDim2.fromScale(0.3, 1)
                        }),
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


                        Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local item = use(self.CurrentSelectedItem) :: string
                            local itemUniqueId = use(self.CurrentSelectedItemUniqueId) :: string

                            local itemInfo = ItemBook:GetItemInfo(item)
                            if itemInfo == nil then
                                return nil
                            end

                            local blackList = { "Material", "Recipe", "Quest", "Passive" }
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
                                table.insert(scope, task.delay(0.3, function()
                                    if self == nil then return end
                                    self.EquipCD = false
                                end))

                                local curItem = Fusion.peek(self.CurrentSelectedItem) :: string
                                local curItemUniqueId = Fusion.peek(self.CurrentSelectedItemUniqueId) :: string

                                if curItem and curItem ~= "" and curItemUniqueId and curItemUniqueId ~= "" then
                                    Events.RequestToEquipItem.Fire({
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
                                    ButtonClickFunc = function()
                                        _requestToEquip()
                                    end
                                })
                            else
                                return ExecuteButton(scope, {
                                    Size = UDim2.fromScale(0.15, 0.7),
                                    ButtonText = "Equip",
                                    ButtonType = "Confirm",
                                    ButtonClickFunc = function()
                                        _requestToEquip()
                                    end
                                })
                            end
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
                            Position = UDim2.fromScale(0.5, 0.5),
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

                        Fusion.ForPairs(scope, { "Accessory", "Weapon", "Active", "Material", "Misc" }, function(_, scope: Fusion.Scope, index: number, category: string)
                            return index, BKCategoryBtn(scope, {
                                Category = category,
                                Index = index,

                                CurrentSelectedItem = self.CurrentSelectedItem,
                                CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,
                                CurrentCategory = self.CurrentCategory,
                            })
                        end)
                    }
                }),

                FakeTopBG(scope)
            }
        },

        CenterProps = {
            ZIndex = 2,

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
        }
    })


    return function ()
        Fusion.doCleanup(scope)


    end
end