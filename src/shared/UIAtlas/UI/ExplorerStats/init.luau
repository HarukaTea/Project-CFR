--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local CharacterStatsView = require(script.Components.CharacterStatsView)
local PlayerActive = require(script.Components.PlayerActives)

local MenuSlot = require(script.Components.MenuSlot)

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


	local scope = self.scope :: Fusion.Scope

	local UI; UI = Components.HarukaScreenGui(scope, {
		Name = "ExplorerStats",
		Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)

	}, {
        BottomProps = {
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
                    Mana = self.Mana, MaxMana = self.MaxMana,

                    ClassUltProgress = self.ClassUltProgress,
                    MaxClassUltProgress = self.MaxClassUltProgress,

                    Class = self.Class
                }, self),


                Components.Frame(scope, {
                    Name = "CastTimeBars",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, -1),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            VerticalAlignment = Enum.VerticalAlignment.Bottom,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        }),

                        Components.UIScale(scope, {
                            Scale = 0.92
                        }),
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
                })
            }
        },
        CenterProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "ItemDropsDiv",
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.fromScale(1, 0),

                    [Children] = {
                        Components.UIScale(scope),

                        Components.Frame(scope, {
                            Name = "ItemDrops",
                            AnchorPoint = Vector2.new(1, 0),
                            Position = UDim2.fromScale(0.99, 0),

                            [Children] = {
                                Components.UIListLayout(scope, {
                                    Padding = UDim.new(0.15, 0),
                                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                    VerticalAlignment = Enum.VerticalAlignment.Top,
                                    SortOrder = Enum.SortOrder.Name,
                                }),
                            }
                        }),
                    }
                }),

                Components.Frame(scope, {
                    Name = "ClassAbilityDiv",
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.fromScale(0, 1.5),

                    [Children] = {
                        Components.UIScale(scope),

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

                        Fusion.ForPairs(scope, { "Backpack", "Character", "Guild", "Settings" }, function(_, scope: Fusion.Scope, index: number, slot: string)
                            return index, MenuSlot(scope, {
                                Slot = slot,
                                Index = index
                            }, self)
                        end)
                    }
                }),

                Components.Frame(scope, {
                    Name = "LevelEXP",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, 1.5),

                    [Children] = {
                        Components.UIScale(scope, {
                            Scale = 0.8
                        }),
                    }
                })
            }
        }
    })
    self.UI = UI


	require(script.Anims)(UI, self)


	return function ()
        Fusion.doCleanup(scope)


    end
end
