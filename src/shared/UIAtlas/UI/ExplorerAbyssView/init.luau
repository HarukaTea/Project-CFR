
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)


local AbyssLevelSlot = require(script.Components.AbyssLevelSlot)
local AbyssEnemySlot = require(script.Components.AbyssEnemySlot)

local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)
local FakeTopBGTex = require(RepS.HarukaShared.UIAtlas.Components.FakeTopBGTex)


local Children = Fusion.Children

local wait = task.wait


local Pinia = require(script.Pinia)

return function (plr: Player)
    local self = {} :: Pinia.Self

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope<any>


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
                Components.Frame(scope, {
                    Name = "AbyssList",
                    Size = UDim2.fromScale(1, 7),
                    Position = UDim2.fromScale(0.5, 1),


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


                                Fusion.ForPairs(scope, table.create(5, true), function(_, scope: Fusion.Scope<any>, index: number, _)
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

                Components.Frame(scope, {
                    Name = "AbyssLevelInfo",
                    Size = UDim2.fromScale(1, 7),
                    Position = UDim2.fromScale(0.5, 1),


                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return use(self.AbyssIndexSelected) ~= nil
                    end),

                    [Children] = {
                        Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return AbyssLevelSlot(scope, {
                                Index = use(self.AbyssIndexSelected) or 1,
                                AbyssIndexSelected = self.AbyssIndexSelected,

                                IsInfoUI = true
                            })
                        end),

                        Components.TextLabel(scope, {
                            Name = "Floor",
                            Position = UDim2.fromScale(0.325, 0.075),
                            Size = UDim2.fromScale(0.5, 0.1),
                            FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                            TextXAlignment = Enum.TextXAlignment.Left,

                            Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                return `Floor {use(self.AbyssIndexSelected)}`
                            end)
                        }),

                        Components.Frame(scope, {
                            Name = "EnemyList",
                            AnchorPoint = Vector2.zero,
                            Position = UDim2.fromScale(0.325, 0.27),
                            Size = UDim2.fromScale(0.5, 0.67),

                            [Children] = {
                                --// FIXME: remember to switch Fusion.Computed when using scrolling in the future
                                Components.UIGridLayout(scope, {
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    VerticalAlignment = Enum.VerticalAlignment.Bottom,
                                    StartCorner = Enum.StartCorner.BottomLeft,

                                    CellPadding = UDim2.fromOffset(12, 12),
                                    CellSize = UDim2.fromScale(0.45, 0.35)
                                }),


                                Fusion.ForPairs(scope, self.AbyssInfo, function(_, scope: Fusion.Scope<any>, mobId: string, mobInfo: {
                                    Level: number,
                                    EnvironmentBonus: number
                                })
                                    return mobId, AbyssEnemySlot(scope, {
                                        MobId = mobId,
                                        MobInfo = mobInfo
                                    })
                                end)
                            }
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
                                if self.Cooldown then return end

                                self.Cooldown = true
                                task.delay(9, function()
                                    self.Cooldown = false
                                end)
                                Bindables.CreateNotify:Fire("Teleporting to Abyss...")

                                Events.RequestToChallengeAbyss.Fire({
                                    AbyssId = Fusion.peek(self.AbyssIndexSelected)
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
                            end
                        }),
                    }
                }),
            }
        }
    })
    self.UI = UI


    return function ()
        Fusion.doCleanup(scope)


    end
end