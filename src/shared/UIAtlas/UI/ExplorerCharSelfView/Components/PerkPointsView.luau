
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Events = require(RepS.HarukaShared.Library.Events)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local FormulaBook = require(RepS.HarukaShared.Library.FormulaBook)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Class: Fusion.Value<string>,
    Level: Fusion.Value<number>,
    EXP: Fusion.Value<number>,
    PerkPoints: Fusion.Value<number>,

    PointList: { [string]: Fusion.Value<number> },
})

    local inputTextbox = Components.TextBox(scope, {
        Name = "AmountInput",
        BackgroundColor3 = Color3.new(),
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(0.2, 1),
        LayoutOrder = 2,
        PlaceholderText = "1",
        FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),

        [Children] = {
            Components.RoundUICorner(scope),
            Components.UIPadding(scope, {})
        }
    })
    local amount = ClientLib:TrackInputTextbox({
        Scope = scope,
        TextBox = inputTextbox,

        Callback = function()

        end
    })

    return Components.Frame(scope, {
        Name = "CharStatsView",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.fromScale(0.97, 1),
        Size = UDim2.fromScale(0.3, 7),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),

        [Children] = {
            Components.UICorner(scope, {
                CornerRadius = UDim.new(0.05, 0)
            }),
            Components.UIListLayout(scope, {
                Padding = UDim.new(0.05, 0),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            }),

            Components.PaddingFrame(scope, "AAA"),

            Components.Frame(scope, {
                Name = "ExplorationLevel",
                BackgroundTransparency = 0,
                BackgroundColor3 = Color3.fromRGB(),
                Size = UDim2.fromScale(0.9, 0.25),
                LayoutOrder = 1,
                ClipsDescendants = true,

                [Children] = {
                    Components.UICorner(scope, {
                        CornerRadius = UDim.new(0.1, 0)
                    }),

                    Components.IconImageLabel(scope, {
                        Name = "Class",
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.fromScale(0.05, 0.5),
                        Size = UDim2.fromScale(0.6, 0.6),

                        Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(props.Class) :: string

                            if not ClassBook[classId] then return AssetBook.ExtraIcons.Unknown end
                            return ClassBook[classId].Icon
                        end),
                        ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(props.Class) :: string

                            if not ClassBook[classId] then return Color3.new(1, 1, 1) end
                            return ClassBook[classId].Color
                        end)
                    }),
                    Components.IconImageLabel(scope, {
                        Name = "ClassBigFade",
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(2, 2),
                        ImageTransparency = 0.85,

                        Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(props.Class) :: string

                            if not ClassBook[classId] then return AssetBook.ExtraIcons.Unknown end
                            return ClassBook[classId].Icon
                        end),
                        ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(props.Class) :: string

                            if not ClassBook[classId] then return Color3.new(1, 1, 1) end
                            return ClassBook[classId].Color
                        end)
                    }),

                    Components.TextLabel(scope, {
                        Name = "PlayerName",
                        Position = UDim2.fromScale(0.25, 0.195),
                        Size = UDim2.fromScale(0.7, 0.23),
                        FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        RichText = true,
                        AutoLocalize = false,

                        Text = HarukaLib:RichTextify(`{Players.LocalPlayer.DisplayName}  <gray>(#{Players.LocalPlayer.UserId})</font>`)
                    }),
                    Components.TextLabel(scope, {
                        Name = "Level",
                        Position = UDim2.fromScale(0.25, 0.54),
                        Size = UDim2.fromScale(0.7, 0.22),
                        FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextColor3 = Color3.fromHex('#7bed9f'),

                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return `Lv.{use(props.Level)}`
                        end)
                    }),
                    Components.TextLabel(scope, {
                        Name = "EXP",
                        Position = UDim2.fromScale(0.25, 0.54),
                        Size = UDim2.fromScale(0.7, 0.22),
                        FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        TextColor3 = Color3.fromHex('#ffeaa7'),

                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local maxEXP = FormulaBook.PlayerLevelCurveCal({
                                Level = use(props.Level)
                            })

                            return `{use(props.EXP)}  /  {maxEXP}`
                        end)
                    }),
                }
            }),

            Components.Frame(scope, {
                Name = "PerkPointInfo",
                Size = UDim2.fromScale(0.9, 0.08),
                LayoutOrder = 2,

                [Children] = {
                    Components.UIAspectRatioConstraint(scope, 12.356),

                    Components.IconImageLabel(scope, {
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.fromScale(0, 0.5),
                        Size = UDim2.fromScale(1.5, 1.5),
                        Image = "rbxassetid://70702384179449"
                    }),

                    Components.TextLabel(scope, {
                        Name = "PointLeft",
                        Position = UDim2.fromScale(0.15, 0),
                        Size = UDim2.fromScale(0.8, 1),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextColor3 = Color3.fromRGB(85, 255, 127),

                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(props.PerkPoints)
                        end)
                    }),

                    Components.Frame(scope, {
                        Name = "Buttons",

                        [Children] = {
                            Components.UIListLayout(scope, {
                                FillDirection = Enum.FillDirection.Horizontal,
                                Padding = UDim.new(0.04, 0),
                                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                            }),

                            Components.TextButton(scope, {
                                Name = "Reset",
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                BackgroundTransparency = 0,
                                LayoutOrder = 233,
                                BackgroundColor3 = Components.RED_COLOR,
                                Text = "R",
                                TextColor3 = Color3.fromRGB(),

                                [Fusion.OnEvent("MouseButton1Click")] = function()
                                    Events.ResetStatPoint_C.Fire()
                                end,

                                [Children] = {
                                    Components.RoundUICorner(scope),
                                }
                            }),

                            Components.TextButton(scope, {
                                Name = "IncreasePoint",
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                BackgroundTransparency = 0,
                                LayoutOrder = 3,
                                BackgroundColor3 = Components.GREEN_COLOR,
                                Text = "+",
                                FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold),
                                TextColor3 = Color3.fromRGB(),

                                [Fusion.OnEvent("MouseButton1Click")] = function()
                                    local curAmount = Fusion.peek(amount)

                                    local nextAmount = curAmount + 1
                                    nextAmount = math.clamp(nextAmount, 1, 99)

                                    amount:set(nextAmount)
                                end,

                                [Children] = {
                                    Components.RoundUICorner(scope),
                                }
                            }),

                            Components.TextButton(scope, {
                                Name = "DecreasePoint",
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                BackgroundTransparency = 0,
                                LayoutOrder = 1,
                                BackgroundColor3 = Components.GREEN_COLOR,
                                Text = "-",
                                FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold),
                                TextColor3 = Color3.fromRGB(),

                                [Fusion.OnEvent("MouseButton1Click")] = function()
                                    local curAmount = Fusion.peek(amount)

                                    local nextAmount = curAmount - 1
                                    nextAmount = math.clamp(nextAmount, 1, 99)

                                    amount:set(nextAmount)
                                end,

                                [Children] = {
                                    Components.RoundUICorner(scope),
                                }
                            }),

                            inputTextbox
                        }
                    }),
                }
            }),

            Components.Frame(scope, {
                Name = "HorizonLine",
                Size = UDim2.fromScale(0.9, 0.005),
                BackgroundTransparency = 0.6,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                LayoutOrder = 3,

                [Children] = {
                    Components.UIAspectRatioConstraint(scope, 197.694)
                }
            }),

            Components.ScrollingFrame(scope, {
                Name = "ExplorationPoints",
                Size = UDim2.fromScale(0.9, 0.437),
                ScrollingDirection = Enum.ScrollingDirection.Y,
                ScrollBarThickness = 5,
                LayoutOrder = 4,

                [Children] = {
                    Fusion.ForPairs(scope, { "STR", "INT", "VIT", "DEX" }, function(_, scope: Fusion.Scope, index: number, point: string)
                        local SYMBOL_ICONS = {
                            STR = "rbxassetid://134445989246357",
                            DEX = "rbxassetid://123194426967050",
                            INT = "rbxassetid://81020560446846",
                            VIT = "rbxassetid://106075217220023",
                            DEF = "rbxassetid://139549262926539"
                        }

                        return index, Components.Frame(scope, {
                            Name = point,
                            Size = UDim2.fromScale(1, 0.23),
                            LayoutOrder = index + 1,
                            BackgroundTransparency = 0,
                            BackgroundColor3 = Color3.fromRGB(),

                            [Children] = {
                                Components.UIAspectRatioConstraint(scope, 9.831),

                                Components.RoundUICorner(scope),

                                Components.IconImageLabel(scope, {
                                    AnchorPoint = Vector2.new(0, 0.5),
                                    Position = UDim2.fromScale(0, 0.5),
                                    Size = UDim2.fromScale(1.2, 1.2),
                                    Image = SYMBOL_ICONS[point],
                                }),
                                Components.TextLabel(scope, {
                                    Name = "Title",
                                    Position = UDim2.fromScale(0.18, 0),
                                    Size = UDim2.fromScale(0.3, 1),
                                    TextColor3 = Color3.fromRGB(129, 236, 236),
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    Text = point,

                                    [Children] = {
                                        Components.UIPadding(scope, {
                                            PaddingTop = UDim.new(0.15, 0),
                                            PaddingBottom = UDim.new(0.15, 0),
                                            PaddingLeft = UDim.new(0, 0),
                                            PaddingRight = UDim.new(0, 0)
                                        })
                                    }
                                }),
                                Components.TextLabel(scope, {
                                    Name = "Stat",
                                    AnchorPoint = Vector2.xAxis,
                                    Size = UDim2.fromScale(0.3, 1),
                                    TextXAlignment = Enum.TextXAlignment.Right,

                                    Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(props.PointList[point])
                                    end),
                                    Position = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        local perkPoints, pointValue = use(props.PerkPoints) :: number, use(props.PointList[point]) :: number

                                        if perkPoints > 0 and pointValue <= 0 then
                                            return UDim2.fromScale(0.825, 0)
                                        elseif perkPoints > 0 and pointValue > 0 then
                                            return UDim2.fromScale(0.725, 0)
                                        elseif perkPoints <= 0 and pointValue > 0 then
                                            return UDim2.fromScale(0.725, 0)
                                        elseif perkPoints <= 0 and pointValue <= 0 then
                                            return UDim2.fromScale(0.925, 0)
                                        end

                                        return UDim2.fromScale(0.925, 0)
                                    end),

                                    [Children] = {
                                        Components.UIPadding(scope, {
                                            PaddingTop = UDim.new(0.15, 0),
                                            PaddingBottom = UDim.new(0.15, 0),
                                            PaddingLeft = UDim.new(0, 0),
                                            PaddingRight = UDim.new(0, 0)
                                        })
                                    }
                                }),
                                Components.TextButton(scope, {
                                    Name = "Increase",
                                    AnchorPoint = Vector2.new(1, 0.5),
                                    Position = UDim2.fromScale(0.95, 0.5),
                                    Size = UDim2.fromScale(0.8, 0.8),
                                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                    BackgroundTransparency = 0,
                                    BackgroundColor3 = Components.GREEN_COLOR,
                                    Text = "+",
                                    TextColor3 = Color3.fromRGB(),
                                    FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold),

                                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(props.PerkPoints) > 0
                                    end),

                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        SoundService.SFXs.Ding:Play()

                                        Events.AddStatPoint_C.Fire({
                                            PointId = point,
                                            PointAmount = Fusion.peek(amount)
                                        })
                                    end,

                                    [Children] = {
                                        Components.RoundUICorner(scope),
                                    }
                                }),
                                Components.TextButton(scope, {
                                    Name = "Decrease",
                                    AnchorPoint = Vector2.new(1, 0.5),
                                    Size = UDim2.fromScale(0.8, 0.8),
                                    Position = UDim2.fromScale(0.85, 0.5),
                                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                    BackgroundTransparency = 0,
                                    BackgroundColor3 = Components.RED_COLOR,
                                    Text = "-",
                                    TextColor3 = Color3.fromRGB(),
                                    FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold),

                                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(props.PointList[point]) > 0
                                    end),

                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        SoundService.SFXs.Ding:Play()

                                        Events.AddStatPoint_C.Fire({
                                            PointId = point,
                                            PointAmount = -Fusion.peek(amount)
                                        })
                                    end,

                                    [Children] = {
                                        Components.RoundUICorner(scope),
                                    }
                                })
                            }
                        })
                    end)
                }
            }, {
                Padding = UDim.new(0, 12),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            }),
        }
    })
end