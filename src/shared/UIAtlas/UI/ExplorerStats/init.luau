--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)

local CharacterStatsView = require(script.Components.CharacterStatsView)
local PlayerActive = require(script.Components.PlayerActives)
local MenuSelections = require(script.Components.MenuSelections)

local MenuSlot = require(script.Components.MenuSlot)
local DungeonTimer = require(script.Components.DungeonTimer)

local Children = Fusion.Children

local wait = task.wait

local classBars = {}
local globalClassBars = {}
for _, bar: ModuleScript in script.Components.ClassPBars:GetChildren() do
    classBars[bar.Name] = require(bar)
end
for _, bar: ModuleScript in script.Components.GlobalClassPBars:GetChildren() do
    if not string.find(bar.Name, "Bar") then continue end

    globalClassBars[bar.Name] = require(bar)
end


return function(plr: Player)
	local self = {}

	self.plr = plr
	self.char = plr.Character
    self.scope = Fusion.scoped()


	require(script.Pinia)(self)


    if plr.PlayerGui:FindFirstChild("ExplorerStats") then
        plr.PlayerGui.ExplorerStats:Destroy()
    end


    local scope = self.scope :: Fusion.Scope
    local isSelectingMenuSelection = Fusion.Value(scope, false)


	local UI; UI = Components.HarukaScreenGui(scope, {
		Name = "ExplorerStats",
		Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)

	}, {
        BottomProps = {
            Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return use(self.IsUIShown2)
            end),

            [Children] = {
                CharacterStatsView(scope, {
                    Class = self.Class,
                    EquippingPassives = self.PassiveList,
                    EquippingItems = self.EquippingItems,

                    HP = self.HP, MaxHP = self.MaxHP,
                    IsHPRecovering = self.IsHPRecovering,

                    Shield = self.Shield, MaxShield = self.MaxShield,

                    MinDMG = self.MinDMG, MaxDMG = self.MaxDMG,
                    Magic = self.Magic
                }),


                PlayerActive(scope, {
                    ClassUltProgress = self.ClassUltProgress,
                    MaxClassUltProgress = self.MaxClassUltProgress,

                    Class = self.Class,
                    ClassVariant = self.ClassVariant
                }, self),


                Components.Frame(scope, {
                    Name = "EffectList",
                    AnchorPoint = Vector2.new(0.5, 1),
                    Position = UDim2.fromScale(0.5, 0.3),
                    Size = UDim2.fromScale(1, 0.7),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            Padding = UDim.new(0.005, 0),
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            SortOrder = Enum.SortOrder.Name,
                        })
                    }
                }),


                Components.TextLabel(scope, {
                    Name = "ServerLocation",
                    Position = UDim2.fromScale(0, 0.5),
                    Size = UDim2.fromScale(1, 0.3),
                    FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold),
                    TextTransparency = 0.3,
                    AutoLocalize = false,

                    Text = Fusion.Computed(scope, function(use: Fusion.Use)
                        return use(self.ServerLocation).." / "..require(RepS.VERSION)
                    end),

                    [Children] = {
                        Components.UITextSizeConstraint(scope, {
                            MaxTextSize = 14
                        })
                    }
                }),

                Components.Frame(scope, {
                    Name = "GlobalClassAbilityDiv",
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.fromScale(0, 1.5),

                    [Children] = {
                        Components.UIScale(scope),

                        Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                            local class = use(self.Class) :: string

                            local Bar = globalClassBars[class.."Bar"]

                            if not Bar then
                                return nil
                            end

                            return Bar(scope, {
                                ClassVal = self.ClassVals[class],
                                ClassVal2 = self.ClassVals2[class],

                                Char = self.char
                            })
                        end)
                    }
                })
            }
        },
        CenterProps = {
            Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return use(self.IsUIShown2)
            end),


            [Children] = {
                Components.Frame(scope, {
                    Name = "ClassAbilityDiv",
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.fromScale(0, 1.5),

                    [Children] = {
                        Components.UIScale(scope, {
                            Scale = 0.95
                        }),

                        Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                            if use(self.IsInCombat) then
                                local class = use(self.Class) :: string

                                local Bar = classBars[class.."Bar"]

                                if not Bar then
                                    return nil
                                end

                                return Bar(scope, {
                                    ClassVal = self.ClassVals[class],
                                    ClassVal2 = self.ClassVals2[class],

                                    Char = self.char
                                })
                            end
                        end)
                    }
                }),


                MenuSelections(scope, {
                    MenuShowValue = self.MenuSelectionShown
                })
            }
        },

        TopProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "Nav",
                    AnchorPoint = Vector2.xAxis,
                    Position = UDim2.fromScale(1, 0.2),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Right,
                            Padding = UDim.new(0.007, 0)
                        }),

                        Components.UIScale(scope),
                        Components.PaddingFrame(scope, "ZZZ"),


                        Components.Frame(scope, {
                            Name = "MenuSelections",
                            BackgroundTransparency = 0,
                            SizeConstraint = Enum.SizeConstraint.RelativeYY,
                            LayoutOrder = 233,

                            [Children] = {
                                Components.RoundUICorner(scope),
                                Components.IconImageLabel(scope, {
                                    Image = "rbxassetid://130903046224988",
                                }),
                                Components.UIStroke(scope, {
                                    Thickness = 2.5,

                                    Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(isSelectingMenuSelection)
                                    end)
                                }),

                                Components.HoverImageButton(scope, {
                                    [Fusion.OnEvent("MouseEnter")] = function()
                                        isSelectingMenuSelection:set(true)
                                    end,
                                    [Fusion.OnEvent("MouseLeave")] = function()
                                        isSelectingMenuSelection:set(false)
                                    end,
                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        self.MenuSelectionShown:set(not Fusion.peek(self.MenuSelectionShown))
                                    end,
                                })
                            }
                        }),


                        Fusion.ForPairs(scope, {
                            "Backpack", "Character", "Settings"
                        }, function(_, scope: Fusion.Scope, index: number, slot: string)
                            return index, MenuSlot(scope, {
                                Slot = slot,
                                Index = index
                            }, self)
                        end)
                    }
                }),

                Components.Frame(scope, {
                    Name = "DungeonStarter",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, 1.5),
                    ZIndex = 5,

                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return use(self.DungeonId) ~= nil and use(self.DungeonStarted) == false
                    end),

                    [Children] = {
                        Components.UIScale(scope, {
                            Scale = 1
                        }),
                        Components.UIListLayout(scope, {
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                        }),

                        Components.TextButton(scope, {
                            Name = "DungeonStart",
                            Size = UDim2.fromScale(0.15, 0.65),
                            Text = "START",
                            BackgroundTransparency = 0,
                            BackgroundColor3 = Components.BLUE_COLOR,
                            TextColor3 = Components.BLACK_TEXT_COLOR,

                            [Fusion.OnEvent("MouseButton1Click")] = function()
                                Events.DUNGEON_RequestToStartDungeon.Fire()
                            end,

                            [Children] = {
                                Components.RoundUICorner(scope),
                                Components.UIPadding(scope, {})
                            }
                        })
                    }
                }),


                Components.Frame(scope, {
                    Name = "DungeonEndActions",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, 1.5),
                    ZIndex = 5,

                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return use(self.DungeonId) ~= nil and use(self.DungeonStarted) and use(self.DungeonFinished) and use(self.DungeonEndActionsClicked) == false
                    end),

                    [Children] = {
                        Components.UIScale(scope, {
                            Scale = 1
                        }),
                        Components.UIListLayout(scope, {
                            Padding = UDim.new(0.5, 0),
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                        }),

                        Components.TextButton(scope, {
                            Name = "DungeonRestart",
                            Size = UDim2.fromScale(0.2, 0.65),
                            Text = "RESTART",
                            BackgroundTransparency = 0,
                            BackgroundColor3 = Components.BLUE_COLOR,
                            TextColor3 = Components.BLACK_TEXT_COLOR,

                            [Fusion.OnEvent("MouseButton1Click")] = function()
                                Events.DUNGEON_RequestToRestartDungeon.Fire()

                                self.DungeonEndActionsClicked:set(true)
                            end,

                            [Children] = {
                                Components.RoundUICorner(scope),
                                Components.UIPadding(scope, {})
                            }
                        }),
                        Components.TextButton(scope, {
                            Name = "DungeonLeave",
                            Size = UDim2.fromScale(0.2, 0.65),
                            Text = "BACK TO INITUS",
                            BackgroundTransparency = 0,
                            BackgroundColor3 = Components.RED_COLOR,
                            TextColor3 = Components.BLACK_COLOR,

                            [Fusion.OnEvent("MouseButton1Click")] = function()
                                Events.DUNGEON_RequestToLeaveDungeon.Fire()

                                self.DungeonEndActionsClicked:set(true)
                            end,

                            [Children] = {
                                Components.RoundUICorner(scope),
                                Components.UIPadding(scope, {})
                            }
                        })
                    }
                }),


                Components.Frame(scope, {
                    Name = "TimerFrame",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, 2),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Center
                        }),
                        Components.UIScale(scope, {
                            Scale = 1
                        }),

                        DungeonTimer(scope, {
                            DungeonId = self.DungeonId,
                            DungeonStarted = self.DungeonStarted,
                            CountdownTime = self.DungeonLeftTime
                        })
                    }
                }),
            }
        }
    })
    self.UI = UI


	require(script.Anims)(UI, self)


	return function ()
        Fusion.doCleanup(scope)
    end
end
