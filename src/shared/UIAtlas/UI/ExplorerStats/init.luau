
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)

local CharacterStatsView = require(script.Components.CharacterStatsView)
local PlayerActive = require(script.Components.PlayerActives)
local MenuSelections = require(script.Components.MenuSelections)

local MenuSlot = require(script.Components.MenuSlot)
local LevelTimer = require(script.Components.LevelTimer)
local LevelStarterComponent = require(script.Components.LevelStarterBtn)

local Children = Fusion.Children

local wait = task.wait

local Pinia = require(script.Pinia)


return function(plr: Player)
	local self = {} :: Pinia.Self

	self.plr = plr
	self.char = plr.Character
    self.scope = Fusion.scoped()


	Pinia(self)


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
                        return use(self.ServerLocation)..", "..use(self.CityLocation).." / "..require(RepS.VERSION)
                    end),

                    [Children] = {
                        Components.UITextSizeConstraint(scope, {
                            MaxTextSize = 14
                        })
                    }
                })
            }
        },
        CenterProps = {
            Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return use(self.IsUIShown2)
            end),


            [Children] = {
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

                        Components.UIScale(scope, {}),
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
                                Components.ScaledUIStroke(scope, {
                                    Thickness = 0.05,

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


                LevelStarterComponent(scope, "Abyss", self),
                LevelStarterComponent(scope, "Dungeon", self),


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

                        LevelTimer(scope, {
                            LevelId = self.DungeonId,
                            LevelStarted = self.DungeonStarted,
                            CountdownTime = self.DungeonLeftTime
                        }),

                        LevelTimer(scope, {
                            LevelId = self.AbyssId,
                            LevelStarted = self.AbyssStarted,
                            CountdownTime = self.AbyssTime
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