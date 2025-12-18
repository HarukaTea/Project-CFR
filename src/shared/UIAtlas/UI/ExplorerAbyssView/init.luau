
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local AbyssBook = require(RepS.HarukaShared.Library.AbyssBook)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)


local AbyssLevelSlot = require(script.Components.AbyssLevelSlot)
local AbyssEnemySlot = require(script.Components.AbyssEnemySlot)
local AbyssRankSlot = require(RepS.HarukaShared.UIAtlas.Components.LBRankSlot)

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


    if plr.PlayerGui:FindFirstChild("ExplorerAbyssView") then
        plr.PlayerGui.ExplorerAbyssView:Destroy()
    end


    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerAbyssView",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)

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

        CenterProps = {
            [Children] = {
                Components.ScrollingFrame(scope, {
                    Name = "AbyssSpeedrunLeaderboard",
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.fromScale(0.02, 1),
                    Size = UDim2.fromScale(0.4, 7.3),
                    ScrollBarThickness = 5,
                    ScrollingDirection = Enum.ScrollingDirection.Y,

                    [Children] = {
                        Components.PaddingFrame(scope, "AAA"),

                        Fusion.ForPairs(scope, self.AbyssRanks, function(_, scope: Fusion.Scope, index: number, val: IntValue)
                            return index, AbyssRankSlot(scope, {
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


                Components.Frame(scope, {
                    Name = "AbyssList",
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.fromScale(0.55, 7),
                    Position = UDim2.fromScale(0.42, 1),


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
                        }),

                        Components.TextLabel(scope, {
                            Name = "AbyssFloorTitle",
                            Position = UDim2.fromScale(0, -0.025),
                            Size = UDim2.fromScale(1, 0.08),
                            Text = "SELECT FLOOR",
                            TextColor3 = Color3.fromRGB(255, 255, 127),

                            [Children] = {
                                Components.ScaledTextUIStroke(scope, {
                                    Thickness = 0.1
                                })
                            }
                        })
                    }
                }),

                Components.Frame(scope, {
                    Name = "AbyssLevelInfo",
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.fromScale(0.55, 7),
                    Position = UDim2.fromScale(0.42, 1),


                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return use(self.AbyssIndexSelected) ~= nil
                    end),

                    [Children] = {
                        Components.TextLabel(scope, {
                            Name = "AbyssModifierTitle",
                            Position = UDim2.fromScale(0, -0.075),
                            Size = UDim2.fromScale(1, 0.08),
                            TextColor3 = Color3.fromRGB(255, 255, 127),


                            Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                local amount = 0
                                for _, chosen in self.ModifierChosen do
                                    if use(chosen) then
                                        amount += 1
                                    end
                                end

                                return `SELECT MODIFIER ({amount})`
                            end),

                            [Children] = {
                                Components.ScaledTextUIStroke(scope, {
                                    Thickness = 0.1
                                })
                            }
                        }),

                        Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return AbyssLevelSlot(scope, {
                                Index = use(self.AbyssIndexSelected) or 1,
                                AbyssIndexSelected = self.AbyssIndexSelected,

                                IsInfoUI = true
                            })
                        end),

                        Components.Frame(scope, {
                            Name = "EnemyList",
                            AnchorPoint = Vector2.yAxis,
                            Position = UDim2.fromScale(0.23, 0.95),
                            Size = UDim2.fromScale(0.8, 0.2),

                            [Children] = {
                                Components.UIListLayout(scope, {
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    Padding = UDim.new(0.03, 0),
                                }),

                                Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                                    local index = use(self.AbyssIndexSelected) or 1

                                    return Fusion.ForValues(scope, AbyssBook.TeamConfigs[index], function(_, scope: Fusion.Scope, mobInfo: AbyssBook.AbyssTeamJSON)
                                        return AbyssEnemySlot(scope, {
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

                                Fusion.ForValues(scope, AbyssBook.Modifiers, function(_, scope: Fusion.Scope, modifier: string)
                                    local isSelecting = Fusion.Value(scope, false)

                                    return Components.Frame(scope, {
                                        Name = "Modifier_"..modifier,
                                        BackgroundTransparency = 0,
                                        Size = UDim2.fromScale(0.95, 0.12),

                                        [Children] = {
                                            Components.UIAspectRatioConstraint(scope, 15.941),
                                            Components.RoundUICorner(scope),
                                            Components.ScaledUIStroke(scope, {
                                                Thickness = 0.05,
                                                Color = Color3.fromHex('#ff7675'),

                                                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                    return use(isSelecting) or use(self.ModifierChosen[modifier])
                                                end)
                                            }),

                                            Components.TextLabel(scope, {
                                                Name = "ModifierTitle",
                                                Text = AbyssBook.ModifierInfo[modifier],
                                                TextXAlignment = Enum.TextXAlignment.Left,

                                                [Children] = {
                                                    Components.UIPadding(scope, {})
                                                }
                                            }),

                                            Components.HoverImageButton(scope, {
                                                [Fusion.OnEvent("MouseButton1Click")] = function()
                                                    self.ModifierChosen[modifier]:set(not Fusion.peek(self.ModifierChosen[modifier]))
                                                end,

                                                [Fusion.OnEvent("MouseEnter")] = function()
                                                    isSelecting:set(true)
                                                end,
                                                [Fusion.OnEvent("MouseLeave")] = function()
                                                    isSelecting:set(false)
                                                end
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
            }
        },

        BottomProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "RSideBtns",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, -0.1),
                    Size = UDim2.fromScale(0.96, 1),


                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return use(self.AbyssIndexSelected) ~= nil
                    end),


                    [Children] = {
                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Right,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            Padding = UDim.new(0.01, 0),
                        }),

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
                                    if Fusion.peek(chosen) then
                                        table.insert(modifiers, modifier)
                                    end
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
                        }),
                    }
                }),


                Components.TextLabel(scope, {
                    Name = "Tip",
                    AnchorPoint = Vector2.new(0.5, 1),
                    Position = UDim2.fromScale(0.5, 0.7),
                    Size = UDim2.fromScale(0.95, 0.5),
                    Text = "SPEEDRUN RECORDS (FLOOR 5 ALL MODIFIERS) [WEEK 3]",
                    TextTransparency = 0.5,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
            }
        }
    })
    self.UI = UI


    return function ()
        Fusion.doCleanup(scope)
    end
end