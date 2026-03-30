
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local AbyssBook = require(RepS.HarukaShared.Library.AbyssBook)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)

local AbyssLevelSlot = require(script.Components.AbyssLevelSlot)
local AbyssEnemySlot = require(script.Components.AbyssEnemySlot)
local LBRankSlot = require(RepS.HarukaShared.UIAtlas.Components.LBRankSlot)

local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)
local FakeTopBGTex = require(RepS.HarukaShared.UIAtlas.Components.FakeTopBGTex)

local BKItemQuickSlot = require(RepS.HarukaShared.UIAtlas.Components.BKItemQuickSlot)

local Children = Fusion.Children

local Pinia = require(script.Pinia)

return function (plr: Player)
    local self = {} :: Pinia.Self

    ClientLib:InitUIFramework(self, plr, "ExplorerAbyssView")

    Pinia(self)

    local scope = self.scope :: Fusion.Scope

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerAbyssView",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("CenterLeft_EAbyss1_1"))({
                [Children] = {
                    Components.ScrollingFrame(scope, {
                        Name = "Items",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.97, 0.95),
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                        ClipsDescendants = false,

                        [Fusion.Out("AbsoluteSize")] = self.ItemListAbsSize,

                        [Children] = {
                            Fusion.ForPairs(scope, self.Items, function(use: Fusion.Use, scope: Fusion.Scope<any>, index: number, itemSymbol: IntConstrainedValue)
                                return index, BKItemQuickSlot(scope, {
                                    ItemSymbol = itemSymbol,

                                    CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,
                                    CurrentSelectedItem = self.CurrentSelectedItem,
                                    CurrentSortOrderList = self.SortMethodList,

                                    IsAbyss = true
                                })
                            end)
                        }
                    }, {
                        CellSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local size = use(self.ItemListAbsSize) :: Vector2
                            local x = size.X * 0.125 * 0.86 * 1.6
                            local y = size.X * 0.135 * 0.86 * 1.6

                            return UDim2.fromOffset(x, y)
                        end),
                        CellPadding = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local size = use(self.ItemListAbsSize) :: Vector2
                            local x = size.X * 0.015 * 1.05
                            local y = size.X * 0.023 * 1.05

                            return UDim2.fromOffset(x, y)
                        end),

                        [Fusion.Out("AbsoluteCellCount")] = self.AvailableItems,

                        FillDirection = Enum.FillDirection.Horizontal,
                    })
                }
            })
        }

    }, {
        FullProps = {
            BackgroundTransparency = 0.3,
            ZIndex = 0,
        },

        TopProps = {
            Position = UDim2.fromScale(0.5, 0.02),

            [Children] = {
                CloseTab(scope, {
                    ViewShownValue = self.IsUIShown
                }),
                FakeTopBGTex(scope)
            }
        },

        CenterChildren = {
            Components.ScrollingFrame(scope, {
                Name = "AbyssSpeedrunLeaderboard",
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0.02, 1),
                Size = UDim2.fromScale(0.4, 7.3),
                ScrollBarThickness = 5,
                ScrollingDirection = Enum.ScrollingDirection.Y,

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(self.AbyssIndexSelected) == nil
                end),

                [Children] = {
                    Components.PaddingFrame(scope, "AAA"),

                    Fusion.ForPairs(scope, self.AbyssRanks, function(_, scope: Fusion.Scope, index: number, val: IntValue)
                        return index, LBRankSlot(scope, {
                            Index = val:GetAttribute("Order"),
                            Value = val.Value,
                            PlayerName = val:GetAttribute("PlayerName"),
                            AvatarId = val:GetAttribute("PlayerThumbnail"),

                            IsAbyss = true
                        })
                    end)
                }

            }, {
                Padding = UDim.new(0, 0),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            }),

            Fusion.Hydrate(scope, Components:RefUI("AbyssList_EAbyss1_1", false, false, {
                "Modifier"
            }))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(self.AbyssIndexSelected) == nil
                end),

                [Children] = {
                    Components.ScrollingFrame(scope, {
                        Name = "AbyssLevels",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.95, 0.95),
                        ScrollingDirection = Enum.ScrollingDirection.X,

                        [Children] = {
                            Components.PaddingFrame(scope, "AAA"),
                            Components.PaddingFrame(scope, "ZZZ"),

                            Fusion.ForPairs(scope, table.create(5, true), function(_, scope: Fusion.Scope, index: number, _)
                                return index, AbyssLevelSlot(scope, {
                                    Index = index,
                                    AbyssIndexSelected = self.AbyssIndexSelected,
                                    IsInfoUI = false
                                })
                            end)
                        }

                    }, {
                        Padding = UDim.new(0, 36),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        FillDirection = Enum.FillDirection.Horizontal,
                    })
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("AbyssList_EAbyss1_1"))({
                Name = "AbyssLevelInfo",

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(self.AbyssIndexSelected) ~= nil
                end),

                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("ModifierChosen_EAbyss2_1", true))({
                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local amount = 0
                            for _, chosen in self.ModifierChosen do
                                if use(chosen) then amount += 1 end
                            end

                            return `SELECT MODIFIER ({amount})`
                        end),
                    }),

                    Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                        return AbyssLevelSlot(scope, {
                            Index = use(self.AbyssIndexSelected) or 1,
                            AbyssIndexSelected = self.AbyssIndexSelected,

                            IsInfoUI = true
                        })
                    end),

                    Fusion.Hydrate(scope, Components:RefUI("EnemyList_EAbyss2_1", true))({
                        [Children] = {
                            Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                                local index = use(self.AbyssIndexSelected)
                                if not index then return nil end

                                return Fusion.ForPairs(scope, AbyssBook.TeamConfigs[index], function(
                                    _,
                                    scope: Fusion.Scope,
                                    index: number,
                                    mobInfo: AbyssBook.AbyssTeamJSON
                                )
                                    return index, AbyssEnemySlot(scope, {
                                        MobId = mobInfo.MobId,
                                        Level = mobInfo.Level
                                    })
                                end)
                            end)
                        }
                    }),

                    Components.ScrollingFrame(scope, {
                        Name = "ModifierList",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0.23, 0),
                        Size = UDim2.fromScale(0.7, 0.7),
                        ScrollingDirection = Enum.ScrollingDirection.Y,

                        [Children] = {
                            Components.PaddingFrame(scope, "AAA"),

                            Fusion.ForPairs(scope, AbyssBook.Modifiers, function(
                                _,
                                scope: Fusion.Scope,
                                index: number,
                                modifier: string
                            )
                                local isSelecting = Fusion.Value(scope, false)

                                return index, Fusion.Hydrate(scope, Components:RefUI("Modifier_EAbyss4_1", false, false, {
                                    "UICorner", "UIAspectRatioConstraint"
                                }))({
                                    [Children] = {
                                        Components.ScaledUIStroke(scope, {
                                            Thickness = 0.05,
                                            Color = Color3.fromHex('#ff7675'),

                                            Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                return use(isSelecting) or use(self.ModifierChosen[modifier])
                                            end)
                                        }),

                                        Fusion.Hydrate(scope, Components:RefUI("ModifierTitle_EAbyss4_2", true))({
                                            Text = AbyssBook.ModifierInfo[modifier]
                                        }),

                                        Components.HoverImageButton(scope, {
                                            Components.ConnectSelectEvents(isSelecting),

                                            [Fusion.OnEvent("MouseButton1Click")] = function()
                                                self.ModifierChosen[modifier]:set(not Fusion.peek(self.ModifierChosen[modifier]))
                                            end,
                                        })
                                    }
                                })
                            end)
                        }
                    }, {
                        Padding = UDim.new(0, 12),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    })
                }
            })
        },

        BottomChildren = {
            Fusion.Hydrate(scope, Components:RefUI("RSideBtns_EAbyss1_1", false, true))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(self.AbyssIndexSelected) ~= nil
                end),

                [Children] = {
                    ExecuteButton(scope, {
                        LayoutOrder = 2,
                        Size = UDim2.fromScale(0.15, 0.7),
                        ButtonText = "Challenge",
                        ButtonType = "Confirm",
                        ButtonClickFunc = function()
                            if self.Cooldown then
                                Bindables.CreateNotify:Fire("Abyss on cooldown: 10s")
                                return
                            end
                            self.Cooldown = true
                            task.delay(9, function()
                                self.Cooldown = false
                            end)
                            Bindables.CreateNotify:Fire("Teleporting to Abyss...")

                            local modifiers = {}
                            for modifier, chosen in self.ModifierChosen do
                                if Fusion.peek(chosen) then table.insert(modifiers, modifier) end
                            end

                            Events.StartAbyss_C.Fire({
                                AbyssId = Fusion.peek(self.AbyssIndexSelected),
                                Modifiers = modifiers
                            })
                        end
                    }),
                    ExecuteButton(scope, {
                        LayoutOrder = 1,
                        Size = UDim2.fromScale(0.15, 0.7),
                        ButtonText = "Back",
                        ButtonType = "Cancel",
                        ButtonClickFunc = function()
                            self.AbyssIndexSelected:set(nil)
                            for _, modifier in self.ModifierChosen do
                                modifier:set(false)
                            end
                        end
                    })
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("Tip_EAbyss1_1"))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local state = use(self.AbyssIndexSelected) == nil

                    return if state then "SPEEDRUN RECORDS (FLOOR 5 ALL MODIFIERS) [VERSION 4]"
                        else "POSSIBLE LOOTS YOU CAN GET"
                end)
            })
        }
    })
    self.UI = UI

    return function ()
        Fusion.doCleanup(scope)
    end
end