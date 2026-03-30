
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local CharacterStatsView = require(script.Components.CharacterStatsView)
local PlayerActivesPC = require(script.Components.PlayerActivesPC)
local PlayerActivesMobile = require(script.Components.PlayerActivesMobile)
local MenuSelections = require(script.Components.MenuSelections)

local MenuSlot = require(script.Components.MenuSlot)
local LevelTimer = require(script.Components.LevelTimer)
local LevelStarterComponent = require(script.Components.LevelStarterBtn)

local HPBar = require(script.Components.HPBar)
local ManaBar = require(script.Components.ManaBar)

local Children = Fusion.Children

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
        FullChildren = {
            Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                local inputType = use(self.LastInputType)

                if inputType == "MobileDevice" then
                    return PlayerActivesMobile(scope, {
                        ClassUltProgress = self.ClassUltProgress,
                        MaxClassUltProgress = self.MaxClassUltProgress,

                        UIViewportSize = self.UIViewportSize,

                        Class = self.Class,
                    }, self)
                end
            end),
        },

        BottomChildren = {
            CharacterStatsView(scope, {
                Class = self.Class,
                EquippingPassives = self.PassiveList,
                EquippingItems = self.EquippingItems,

                MinDMG = self.MinDMG, MaxDMG = self.MaxDMG,
                Magic = self.Magic,

                Gold = self.Gold
            }),

            Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                local inputType = use(self.LastInputType)

                if inputType ~= "MobileDevice" then
                    return PlayerActivesPC(scope, {
                        ClassUltProgress = self.ClassUltProgress,
                        MaxClassUltProgress = self.MaxClassUltProgress,

                        Class = self.Class,
                    }, self)
                end
            end),

            Fusion.Hydrate(scope, Components:RefUI("StatsFrame_PStats1_1", false, true))({
                [Children] = {
                    Components.UIScale(scope, {
                        Scale = if self.Device == "Phone" or self.Device == "Tablet" then 1.1 else 1
                    }),

                    HPBar(scope, {
                        HP = self.HP, MaxHP = self.MaxHP,
                        Shield = self.Shield, MaxShield = self.MaxShield
                    }),
                    ManaBar(scope, {
                        Mana = self.Mana, MaxMana = self.MaxMana,
                    })
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("EffectList_PStats1_1", true))({}),

            Fusion.Hydrate(scope, Components:RefUI("ServerLocation_PStats1_1", true))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use)
                    return use(self.ServerLocation)..", "..use(self.CityLocation).." / "..require(RepS.VERSION)
                end),
            })
        },
        BottomProps = {
            Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return use(self.IsUIShown2)
            end),
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

        TopChildren = {
            Fusion.Hydrate(scope, Components:RefUI("Nav_PStats1_1", false, true, { "ZZZ_ZZZ" }))({
                [Children] = {
                    Fusion.ForPairs(scope, {
                        "Backpack", "Character", "Settings"
                    }, function(_, scope: Fusion.Scope, index: number, slot: string)
                        return index, MenuSlot(scope, {
                            Slot = slot,
                            Index = index
                        }, self)
                    end),

                    Fusion.Hydrate(scope, Components:RefUI("MenuSelections_PStats1_1", false, false, {
                        "UICorner"
                    }))({
                        [Children] = {
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
                                Components.ConnectSelectEvents(isSelectingMenuSelection),

                                [Fusion.OnEvent("MouseButton1Click")] = function()
                                    self.MenuSelectionShown:set(not Fusion.peek(self.MenuSelectionShown))
                                end,
                            })
                        }
                    })
                }
            }),

            LevelStarterComponent(scope, "Abyss", self),
            LevelStarterComponent(scope, "Dungeon", self),

            Fusion.Hydrate(scope, Components:RefUI("TimerFrame_PStats1_1", false, true))({
                [Children] = {
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
            })
        }
    })
    self.UI = UI

	require(script.Anims)(UI, self)

	return function ()
        Fusion.doCleanup(scope)
    end
end